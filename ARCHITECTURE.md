# Ramen Architecture

## Overview

Ramen is a static site generator built with OCaml that follows a clear architectural separation between pure functional logic and I/O operations. This design enables better testability, potential JavaScript compilation, and cleaner code organization.

## Core/Lib Separation

The most fundamental architectural principle in Ramen is the strict separation between:

- **`lib/core/`** - Pure functional logic with no side effects
- **`lib/`** - I/O-bound operations and system interactions

### lib/core/ - Pure Functional Core

The `lib/core/` directory contains all pure, side-effect-free code:

- **No file I/O operations**
- **No network calls**  
- **No system interactions**
- **Only data transformations and business logic**

This design has several benefits:
1. **Testability**: Pure functions are easy to test with predictable inputs/outputs
2. **JavaScript Compilation**: The core can be compiled to JavaScript using js_of_ocaml
3. **Reasoning**: Pure code is easier to understand and reason about
4. **Reusability**: Core logic can be used in different contexts (CLI, web, etc.)

The core contains:
- Data type definitions
- Business logic transformations
- Validation rules
- Utility functions

### lib/ui/ - Pure UI Components

The `lib/ui/` directory contains pure functions for generating HTML:

- **Stateless HTML generation**
- **Reusable UI components**
- **No side effects or I/O**
- **Composable building blocks**

UI components are pure functions that take data and return HTML structures, making them easy to test and reuse across different pages.

### lib/views/ - Page Generators

The `lib/views/` directory contains modules that combine UI components to create complete pages:

- **Orchestrates UI components**
- **Defines page layouts and structure**
- **Handles page-specific logic**
- **Still pure - returns HTML structures**

Views are responsible for assembling UI components into complete pages but remain pure by returning data structures rather than performing I/O.

### lib/ - I/O and System Bridge

The root `lib/` directory acts as a bridge between the pure modules and the operating system:

- **File reading/writing operations**
- **Directory traversal**
- **HTTP server functionality**
- **Command-line interface**
- **External tool integration**

This layer handles all the messy real-world interactions while keeping the core logic pure and testable.

## Three Build Modes

Ramen supports three different build modes, each optimized for different use cases:

### 1. Static Build (`ramen build`)

**Use case**: Traditional static site generation for hosting on GitHub Pages, Netlify, etc.

**How it works**:
- Loads data from `data/` directory at build time
- Generates complete static HTML files
- Outputs to `_site/` directory
- Generates `search-index.json` for client-side search
- Zero runtime dependencies

**Search**: Uses `search_static.js` which loads `/search-index.json` via fetch()

### 2. Dynamic Serve (`ramen serve`)

**Use case**: Development with live reload, or dynamic serving in production

**How it works**:
- Loads data from `data/` directory on server startup
- Watches for file changes and reloads automatically
- Serves pages dynamically via HTTP
- Can implement server-side search endpoints

**Search**: Can use server-side search API or generate search index on the fly

### 3. Crunched/Embedded (`ramen crunch`)

**Use case**: Compile everything into a single binary, perfect for js_of_ocaml

**How it works**:
- Pre-compiles all data into OCaml modules
- No runtime file I/O needed
- Can be compiled to JavaScript with js_of_ocaml
- Perfect for single-page apps or embedded use

**Search**: Uses compiled-in search data via `Search_data` module

## Stateless Architecture

All modes follow the same stateless pattern:

```ocaml
(* 1. Load data once *)
let data = Data.load_site ~data_dir

(* 2. Pass data explicitly to all functions *)
Engine.generate ~data_dir ~output_dir ~data
Pages.render ~site:data.site data page
Search_generator.search_posts ~query data
```

No global state, no mutable variables, pure functions throughout.

## Module Responsibilities

- **Core**: Type definitions and business logic
- **Data**: Loading data from disk into Core types
- **Engine**: Orchestrating the build process
- **Views**: Rendering pages to HTML
- **Search_generator**: Creating search indices for different modes
- **Validation**: Ensuring data integrity

## Data Flow

```
data/ directory
    ↓
Data.load_site
    ↓
Core.t record
    ↓
┌─────────────┬──────────────┬─────────────┐
│ Static Mode │ Dynamic Mode │ Crunch Mode │
├─────────────┼──────────────┼─────────────┤
│ Engine      │ Serve        │ Crunch      │
│ generates   │ renders      │ generates   │
│ HTML files  │ on request   │ OCaml code  │
└─────────────┴──────────────┴─────────────┘
```