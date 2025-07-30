# TODO

## Tailwind CSS Implementation

### Completed
- [x] Add missing extended color palette (slate, zinc, orange, amber, lime, emerald, cyan, violet, fuchsia, rose)
- [x] Fix failing tests (CSS property ordering, URLs, missing functions)
- [x] Add comprehensive Tailwind tests for all features
- [x] Optimize Tailwind tests by batching CSS generation
- [x] Fix CSS generation to match Tailwind 1:1
- [x] Add more comprehensive Tw classes to test coverage
- [x] Ensure dune build and dune test work correctly
- [x] Implement filters (blur, brightness, contrast, grayscale)
- [x] Add core animations (spin, pulse, bounce, ping)
- [x] Add table utilities (table layout, display, border spacing)
- [x] Add overflow variants and grid utilities
- [x] Fix duplicate definitions and inconsistent naming patterns
- [x] Add proper documentation links to tw.mli sections
- [x] Add form styling utilities (equivalent to @tailwindcss/forms plugin)
- [x] Add peer and ARIA state variants support
- [x] Remove broken (@>) operator
- [x] Replace frequently used Css.Custom properties with proper variants
- [x] Fix duplicate Flex_shrink in CSS type definition
- [x] Replace Custom "color" with proper Color property
- [x] Add backdrop-filter utilities (backdrop-blur, backdrop-brightness, etc.)
- [x] Add scroll-snap utilities (snap-x, snap-y, snap-center, scroll-smooth, etc.)
- [x] Update module header with better documentation and usage example

### Pending
- [ ] Reorganize tw.mli sections for more intuitive ordering (Core Types → Color & Background → Spacing → Sizing → Layout → Typography → Borders → Effects & Filters → Transitions & Animations → Tables → Forms → State & Responsive Modifiers → Class Generation & Internals)
- [ ] Add support for data-* attribute variants (e.g., data-[state=open]:)

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