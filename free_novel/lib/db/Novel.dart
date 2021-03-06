
class Novel{
  final int id;
  final int page;
  final String title;
  String content;
  int status = 0;
  String url = "";

  Novel(
  {this.id, this.page, this.title, this.content, this.url});

  factory Novel.fromJson(Map<String, dynamic> parsedJson){
    var novel =  Novel(
        id:parsedJson['id'],
        page:parsedJson['page'],
        title:parsedJson["title"],
        content:parsedJson ['content']
    );
    novel.status = parsedJson['status'];
    novel.url = parsedJson['url'];
    return novel;
  }

  factory Novel.fromJsonNoContent(Map<String, dynamic> parsedJson){
    var novel =  Novel(
        id:parsedJson['id'],
        page:parsedJson['page'],
        title:parsedJson["title"],
        content:""
    );
    novel.status = parsedJson['status'];
    return novel;
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'page': page, 'title': title, 'content': content, 'url':url, 'status':status};
  }
}