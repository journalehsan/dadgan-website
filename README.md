# موسسه حقوقی دادگان - Persian Law Firm Website

A modern, SEO-optimized website for a Persian law firm specializing in divorce and family law services, built with Rust and Actix Web.

## Features

- **Responsive Design**: Mobile-first design with Tailwind CSS
- **SEO Optimized**: Meta tags, structured data, and semantic HTML
- **Persian Language Support**: RTL layout and Persian fonts (Vazir)
- **Modular Templates**: Clean separation of layout and partials
- **Fast Performance**: Built with Rust and Actix Web
- **Modern UI**: Beautiful gradient backgrounds and smooth animations

## Sections

- **Hero Section**: Main landing area with call-to-action buttons
- **Services**: Divorce consultation, family law advice, and court representation
- **About**: Company information and credentials
- **Pricing**: Service packages and pricing information
- **FAQ**: Frequently asked questions about divorce and family law
- **Contact**: Contact form and business information

## Technology Stack

- **Backend**: Rust with Actix Web
- **Templating**: Askama with Jinja2-like syntax
- **Styling**: Tailwind CSS with custom Persian fonts
- **Icons**: Ionicons
- **Fonts**: Vazir (Persian font)

## Getting Started

### Prerequisites

- Rust (latest stable version)
- Cargo

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd dadgan-website
```

2. Build the project:
```bash
cargo build
```

3. Run the application:
```bash
cargo run
```

4. Open your browser and navigate to `http://localhost:8081`

## Project Structure

```
dadgan-website/
├── src/
│   └── main.rs              # Main application code
├── templates/
│   ├── layout.html          # Base layout template
│   ├── index.html           # Home page template
│   └── partials/            # Reusable template components
│       ├── header.html      # Navigation header
│       ├── footer.html      # Site footer
│       ├── hero.html        # Hero section
│       ├── services.html    # Services section
│       ├── about.html       # About section
│       ├── pricing.html     # Pricing section
│       ├── faq.html         # FAQ section
│       └── contact.html     # Contact section
├── static/                  # Static files
│   ├── robots.txt          # SEO robots file
│   └── sitemap.xml         # SEO sitemap
├── Cargo.toml              # Rust dependencies
└── askama.toml             # Template configuration
```

## SEO Features

- **Meta Tags**: Comprehensive meta tags for search engines
- **Open Graph**: Social media sharing optimization
- **Structured Data**: JSON-LD structured data for rich snippets
- **Sitemap**: XML sitemap for search engine crawling
- **Robots.txt**: Search engine crawling instructions
- **Semantic HTML**: Proper HTML5 semantic elements

## Customization

### Adding New Sections

1. Create a new partial template in `templates/partials/`
2. Include it in the main template using `{% include "partials/your-section.html" %}`
3. Add any necessary data structures in `main.rs`

### Styling

The website uses Tailwind CSS with custom Persian color schemes. Modify the Tailwind configuration in `templates/layout.html` to change colors and fonts.

### Content

Update the Persian content directly in the template files. All text is in Persian and optimized for Iranian law firm services.

## License

This project is licensed under the MIT License.

## Contact

For questions about this website implementation, please contact the development team.
