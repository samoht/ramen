# RFC-003: Comprehensive Documentation

**Status: Proposed**

## Summary

This RFC proposes a plan to create comprehensive documentation for Ramen, targeting its two distinct user groups: CLI users and OCaml library users.

## Motivation

To support both user groups effectively, the documentation must be structured to provide clear, role-specific guidance. A CLI user should not need to read API documentation, and a library user needs more than just Markdown tutorials.

## Proposal: A Two-Part Documentation Site

The documentation will be a website built with Ramen itself, organized into two main sections.

### Part 1: For CLI Users

This section is for users who want to build a static site without writing OCaml code.

1.  **Tutorials / Getting Started:**
    -   A "Getting Started" guide that walks a new user through `ramen init`, creating their first post, and using `ramen serve`.
    -   This will be the primary entry point for new users.

2.  **How-To Guides:**
    -   Goal-oriented guides for common tasks.
    -   "How to Add and Manage Content (Posts, Pages, etc.)"
    -   "How to Configure Your Site (`site.yml`)"
    -   "How to Install and Use a Custom Theme" (depends on the theme system)
    -   "How to Customize a Theme's CSS and Settings" (depends on the theme system)

3.  **Deployment Guides:**
    -   Step-by-step instructions for deploying a Ramen site to popular static hosting providers (GitHub Pages, Netlify, Vercel).

### Part 2: For Library Users (OCaml Developers)

This section is for developers who want to use Ramen as a library within a larger OCaml application.

1.  **API Reference:**
    -   Generated API documentation (`.mld` files) for the core libraries (`Ramen.Core`, `Ramen.Builder`).
    -   This will detail the key modules and types like `Core.Types`, `Core.Data`, and the function signatures for building the site.

2.  **How-To Guides:**
    -   "How to Integrate Ramen with a Dream Server" (based on the `example/dream` proof-of-concept).
    -   "How to Create a Custom Theme" (explaining how to implement the `Theme.S` signature).
    -   "How to Create a Content Plugin" (explaining how to implement the `Plugin.S` signature).

### Implementation Plan

1.  Restructure the `example/` directory to serve as the source for the new, two-part documentation site.
2.  Write the content for each of the sections described above.
3.  The official documentation website for Ramen will be a public, hosted version of this site.