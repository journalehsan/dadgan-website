use actix_web::{web, App, HttpServer, Result, HttpResponse};
use askama::Template;

#[derive(Template)]
#[template(path = "index.html")]
struct IndexTemplate;

async fn index() -> Result<HttpResponse> {
    let template = IndexTemplate {};
    let html = template.render().unwrap();
    Ok(HttpResponse::Ok()
        .content_type("text/html; charset=utf-8")
        .body(html))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    println!("Starting Dadgan Law Firm website on http://localhost:8081");
    
    HttpServer::new(|| {
        App::new()
            .service(actix_files::Files::new("/static", "./static").show_files_listing())
            .route("/", web::get().to(index))
    })
    .bind("127.0.0.1:8081")?
    .run()
    .await
}
