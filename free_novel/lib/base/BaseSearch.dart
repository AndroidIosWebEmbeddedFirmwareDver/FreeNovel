import "package:novel/utils/DioHelper.dart";
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

abstract class BaseSearch {
  static const PARENT_CLASS = "parent";
  static const ITEM_CLASS = "item";
  static const ITEM_ID = "id";
  static const ITEM_PATH = "path";
  static const ITEM_URL = "url";
  static const ITEM_TITLE = "title";

  Map<String, dynamic> getParams(String query);
  String getSearchUrl();
  static List<String> _downloadUrls = [];

  doSearch<T>(String query,
      {Function(T t) success, Function(int errorType) error}) async {
    DioHelper.doGet(getSearchUrl(),
        params: getParams(query), success: success, error: error);
  }

  Future<dynamic> parseResult(String response);

  downloadItem(String url) async {
    if (url.isEmpty || _downloadUrls.contains(url)) {
      return;
    }
    _downloadUrls.add(url);
    print("downloadItem:$url");
    DioHelper.doGet(url, params: null, success: (response){
      print("response:$response");
      parseItem(response);
      _downloadUrls.remove(url);
    }, error: (errorType) {
      print("errorType:$errorType");
      _downloadUrls.remove(url);
    });
  }

  List<Element> _getTargetElement(String response, Map<String, dynamic> params) {
    var document = parse(response);
    String itemClass = params[ITEM_CLASS];
    if(itemClass != null && itemClass.length > 0) {
      return document.querySelectorAll(itemClass);
    }
    String itemId = params[ITEM_ID];
    String itemPath = params[ITEM_PATH];
    if(itemId != null && itemId.length > 0) {
      var item = document.getElementById(itemId);
      if(itemPath == null || itemPath.length == 0) {
        return [item];
      }
      return item.querySelectorAll(itemPath);
    }
    String parentClass = params[PARENT_CLASS];
    assert(parentClass!= null && parentClass.length > 0);
    final parentItem = document.querySelector(".$parentClass");
    return parentItem.querySelectorAll(itemPath);
  }

  Map<String, dynamic> getItemParams();
  dynamic parseItemContent(Element element);
  String getBaseUrl();

  Future<dynamic> parseItem(String response) async{
    final itemParams = getItemParams();
    List<Element> lists = _getTargetElement(response, itemParams);
    List<Map<String, String>> items = [];
    items = List.generate(lists.length, (i){
      return parseItemContent(lists[i]);
    });
    print("Items:${items}");
    items.forEach((element) {
      String url = getBaseUrl() + element[ITEM_URL];
      downloadContent(url);
    });
    return items;
  }

  downloadContent(String url) async {
    if (url.isEmpty || _downloadUrls.contains(url)) {
      return;
    }
    _downloadUrls.add(url);
    print("downloadContent:$url");
    DioHelper.doGet(url, params: null, success: (response){
      parseContentResponse(response);
      _downloadUrls.remove(url);
    }, error: (errorType) {
      _downloadUrls.remove(url);
    });
  }

  Map<String, dynamic> getContentParams();
  dynamic parseContent(Element element);

  Future<dynamic> parseContentResponse(String response) async{
    final params = getContentParams();
    Element element = _getTargetElement(response, params)[0];
    dynamic content = parseContent(element);
    print("content:$content");
    return content;
  }
}
