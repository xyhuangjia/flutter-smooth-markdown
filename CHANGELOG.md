# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.2] - 2025-11-20

### Added
- ✅ **Details & Summary Support** - Collapsible content sections with interactive expand/collapse
  - Support for HTML `<details>` and `<summary>` tags
  - Automatic parsing of nested markdown content
  - Click-to-expand/collapse functionality with animated arrow icons
  - Default open state via `open` attribute
  - Seamless integration with both standard and enhanced component modes

### Implementation
- Added `DetailsNode` to AST for representing collapsible sections
- Implemented `DetailsBuilder` widget with stateful expand/collapse behavior
- Parser logic for `<details>` and `<summary>` HTML tags
- Registered builder in both default and enhanced component registries
- Comprehensive test coverage (11 parser tests + 7 renderer tests)

### Examples
```markdown
<details>
<summary>Click to expand</summary>
Hidden content that shows on click
</details>

<details open>
<summary>Expanded by default</summary>
This section starts expanded
</details>
```

## [0.3.1] - 2025-11-18

### Fixed
- 🐛 **Table rendering crash** - Fixed "irregular row lengths" error
  - Tables with inconsistent column counts now render correctly
  - Automatically fills missing cells with empty content
  - Calculates correct column count from headers, alignments, and data rows
  - Handles edge cases (empty tables, varying row lengths)

### Technical Details
- Improved table column count calculation logic in `TableBuilder`
- Replaced problematic `double.infinity.toInt()` with safe max calculation
- Added defensive checks to ensure at least 1 column in all tables

## [0.3.0] - 2025-11-18

### 🚀 Major Performance Improvements
- **32x Faster Rendering** - LRU parse cache dramatically improves performance
- **Smooth Scrolling** - 60 FPS in chat/list scenarios with 50+ messages
- **Memory Efficient** - Smart caching with automatic eviction

### Added
- ✅ **MarkdownParseCache** - LRU cache for parsed AST nodes
  - Cache hit: ~0.1ms vs ~3.6ms parsing (32x faster)
  - Configurable size (default: 100 entries)
  - Automatic LRU eviction
  - Cache statistics API
- ✅ **SmoothMarkdown enhancements**:
  - `enableCache` parameter (default: true) - Enable/disable parse caching
  - `useRepaintBoundary` parameter (default: true) - Isolate widget repaints
  - `SmoothMarkdown.clearCache()` - Clear global cache
  - `SmoothMarkdown.cacheStatistics` - Get cache usage stats
- ✅ **StreamMarkdown optimizations**:
  - Throttling mechanism (50ms) - Batch rapid stream updates
  - Automatic RepaintBoundary - Reduce overdraw
  - Smart cache management - Disable cache for streaming content
- ✅ **Performance Testing**:
  - Comprehensive cache performance tests (8 test cases)
  - Benchmark results included in documentation
  - Chat scenario simulation tests
- ✅ **Chat List Demo** - Production-ready chat interface example
  - ChatGPT-like UI with message bubbles
  - Real-time AI streaming responses
  - Dark/light theme support
  - Performance optimizations showcase
  - Cache statistics viewer

### Documentation
- 📚 Complete performance optimization guide (`doc/AI聊天列表性能优化.md`)
- 📊 Performance benchmarks and comparisons
- 💡 Best practices for list/chat scenarios
- 🎯 Optimization implementation summary (`doc/性能优化总结.md`)

### Performance Impact
- **List Scrolling**: 45 FPS → 60 FPS (+33%)
- **Repeated Rendering**: 3.6ms → 0.11ms (32x faster)
- **Chat Scenario**: 99.5% cache hit rate
- **Memory Overhead**: ~50KB per cached entry

### Breaking Changes
None - All optimizations are opt-in or enabled by default without breaking existing code.

## [0.2.0] - 2025-11-18

### Major Improvements
- 📚 **Complete API Documentation** - Comprehensive dartdoc for all public APIs
- 🎯 **Developer Experience** - Significantly improved IDE code completion
- 📖 **Production Ready** - Professional-grade documentation quality

### Added
- Extensive documentation for SmoothMarkdown and StreamMarkdown widgets
- Complete MarkdownStyleSheet documentation with all factory methods
- Detailed MarkdownConfig documentation with security and performance notes
- Full MarkdownRenderer documentation including custom builder examples
- Multiple code examples and usage scenarios throughout the codebase
- Performance considerations and best practices in documentation
- Cross-references between related classes for better navigation

### Improved
- API documentation quality elevated to production standards
- Better IDE experience with detailed parameter descriptions
- Structured documentation with clear sections and examples
- Enhanced developer onboarding experience

## [0.1.9] - 2025-11-18

### Added
- Comprehensive dartdoc documentation for all public APIs
- Detailed documentation for core widgets (SmoothMarkdown, StreamMarkdown)
- Complete documentation for MarkdownStyleSheet with all factory methods
- Extensive documentation for MarkdownConfig with security and performance notes
- Full documentation for MarkdownRenderer including custom builder examples
- Multiple code examples and usage scenarios for each API
- Performance considerations and best practices throughout

### Improved
- API documentation quality significantly enhanced
- Better IDE code completion experience with detailed parameter descriptions
- Added "See also" cross-references between related classes
- Structured documentation with sections for features, usage, and examples

## [0.1.8] - 2025-11-18

### Removed
- Removed unused `markdown: ^7.0.0` dependency (package uses custom parser implementation)

### Changed
- Reduced package size by removing unnecessary dependencies

## [0.1.7] - 2025-11-18

### Changed
- Package maintenance release
- Ensure all documentation is synchronized

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

[Unreleased]: https://github.com/JackCaow/flutter-smooth-markdown/compare/v0.1.8...HEAD
[0.1.8]: https://github.com/JackCaow/flutter-smooth-markdown/compare/v0.1.7...v0.1.8
[0.1.7]: https://github.com/JackCaow/flutter-smooth-markdown/compare/v0.1.6...v0.1.7
[0.1.6]: https://github.com/JackCaow/flutter-smooth-markdown/compare/v0.1.5...v0.1.6
[0.1.5]: https://github.com/JackCaow/flutter-smooth-markdown/compare/v0.1.4...v0.1.5
[0.1.4]: https://github.com/JackCaow/flutter-smooth-markdown/compare/v0.1.3...v0.1.4
[0.1.3]: https://github.com/JackCaow/flutter-smooth-markdown/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/JackCaow/flutter-smooth-markdown/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/JackCaow/flutter-smooth-markdown/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/JackCaow/flutter-smooth-markdown/releases/tag/v0.1.0
