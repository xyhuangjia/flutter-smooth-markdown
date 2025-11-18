# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.7] - 2025-11-18

### Changed
- Package maintenance release
- Ensure all documentation is synchronized

### Removed
- Removed unused `markdown: ^7.0.0` dependency (package uses custom parser implementation)

## [0.1.6] - 2024-11-18

### Changed
- Enhanced package description with more keywords for better discoverability
- Added topics/tags to pubspec.yaml (markdown, renderer, syntax-highlighting, latex, streaming, widget, ui)
- Added pub.dev badges to README
- Added use cases section to README
- Added keywords section for SEO optimization

## [0.1.5] - 2024-11-18

### Documentation
- Updated installation instructions to reference version 0.1.4
- Ensured README shows latest version for new users

## [0.1.4] - 2024-11-18

### Changed
- Adjusted README screenshot display size to 600px width for better readability

## [0.1.3] - 2024-11-18

### Added
- Demo screenshots showcasing package features:
  - Main interface (main.jpg)
  - Code blocks with syntax highlighting (code.jpg)
  - LaTeX math formula rendering (latx.jpg)
  - Streaming markdown rendering (streaming.gif)

### Documentation
- Updated README with actual demo screenshots
- Improved visual presentation of package capabilities

## [0.1.2] - 2024-11-18

### Documentation
- Replaced example.com placeholder image links with real, working URLs
- Added Demo section showcasing package features
- Created screenshots directory structure for future demo images
- Updated image examples with Flutter logo and SVG icon
- Added streaming support to features list in README

## [0.1.1] - 2024-11-18

### Documentation
- Updated README to reflect Phase 4 (Stream support) completion status
- Clarified that streaming functionality is fully implemented with StreamMarkdown widget
- Added streaming demo reference in roadmap

## [0.1.0] - 2024-11-18

### Added
- Initial release of Flutter Smooth Markdown
- AST-based markdown parser with full CommonMark support
- Widget builder system for extensible rendering
- Built-in themes: Default (Light/Dark), GitHub (Light/Dark), VS Code (Light/Dark)
- Enhanced UI components:
  - Code blocks with syntax highlighting and copy functionality
  - Blockquotes with gradient backgrounds and quote icons
  - Links with hover animations and external indicators
  - Headers with decorative accents
- Basic markdown syntax support:
  - Headers (H1-H6)
  - Text formatting (bold, italic, strikethrough, inline code)
  - Lists (ordered, unordered, task lists)
  - Code blocks with syntax highlighting
  - Links and images
  - Blockquotes
  - Horizontal rules
- Customizable style sheets with theme inheritance
- Example application demonstrating all features
- Comprehensive documentation in Chinese

### Technical
- Minimum SDK version: Dart >=3.0.0, Flutter >=3.0.0
- Dependencies:
  - markdown: ^7.0.0
  - flutter_highlight: ^0.7.0
  - cached_network_image: ^3.3.0
  - url_launcher: ^6.2.0
  - flutter_math_fork: ^0.7.2
  - flutter_svg: ^2.0.10+1
- 87+ unit tests with comprehensive coverage
- Flutter lints enabled for code quality

[Unreleased]: https://github.com/JackCaow/flutter-smooth-markdown/compare/v0.1.7...HEAD
[0.1.7]: https://github.com/JackCaow/flutter-smooth-markdown/compare/v0.1.6...v0.1.7
[0.1.6]: https://github.com/JackCaow/flutter-smooth-markdown/compare/v0.1.5...v0.1.6
[0.1.5]: https://github.com/JackCaow/flutter-smooth-markdown/compare/v0.1.4...v0.1.5
[0.1.4]: https://github.com/JackCaow/flutter-smooth-markdown/compare/v0.1.3...v0.1.4
[0.1.3]: https://github.com/JackCaow/flutter-smooth-markdown/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/JackCaow/flutter-smooth-markdown/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/JackCaow/flutter-smooth-markdown/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/JackCaow/flutter-smooth-markdown/releases/tag/v0.1.0
