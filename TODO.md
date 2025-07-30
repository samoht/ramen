# TODO

## High Priority

- [ ] Add pagination to blog index
  - Currently showing all posts on one page
  - Add year-based filtering or grouping
  - Implement proper pagination controls

- [ ] Add proper XML validation for RSS feeds and sitemaps

## Medium Priority

- [ ] Create proper deduplication system for posts from multiple platforms
  - Need to identify duplicate posts by title/date similarity
  - Merge source links for duplicate posts

- [ ] Add logos for socials
- [ ] Create drafts section for experimental/future-dated blog posts

## Design Improvements

- [ ] Create consistent hero component for all pages
  - Currently index, blog pages have different hero styles
  - Ensure consistent spacing, typography, and background treatment

- [ ] Strengthen visual hierarchy with more contrast between sections
- [ ] Add visual breaks or different font weights to create more rhythm on the page
- [ ] Use different typography scales for better content flow
- [ ] Enhance hover states with more visual feedback
- [ ] Improve spacing and whitespace usage for better visual breathing room

## Server & Infrastructure Features

### Production-Grade Web Server
- [ ] Implement production web server with middlewares
  - [ ] Add request logging middleware
  - [ ] Add compression middleware (gzip/brotli)
  - [ ] Add security headers middleware
  - [ ] Add request rate limiting
  - [ ] Add proper error handling middleware

### Livereload WebSocket Server
- [ ] Implement livereload functionality
  - [ ] WebSocket server for development mode
  - [ ] File watching with inotify/fswatch
  - [ ] Automatic browser refresh on file changes
  - [ ] Inject livereload script in development mode

### Content-Based Asset Hashing
- [ ] Implement asset hashing system
  - [ ] Generate content-based hashes for all static assets
  - [ ] Rewrite asset URLs in HTML with hashed versions
  - [ ] Create manifest file mapping original to hashed names
  - [ ] Add far-future cache headers for hashed assets
  - [ ] Ensure CSS/JS references are updated

### Responsive Image Generation
- [ ] Implement responsive image generation
  - [ ] Generate multiple sizes for each image (srcset)
  - [ ] Support WebP/AVIF format conversion
  - [ ] Add lazy loading attributes
  - [ ] Generate low-quality image placeholders (LQIP)
  - [ ] Update HTML to use picture elements with srcset

## Theming System (See todo/theme.md)

- [ ] Implement configuration-driven theming for CLI users
- [ ] Implement functor-based theming system for library users
- [ ] Create theme.yml configuration file support
- [ ] Document theming system