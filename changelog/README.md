# Helm Charts Changelog

This directory contains the interactive changelog viewer for the Grafana Community Helm Charts project.

## About

The `index.html` file is an interactive web application that displays the complete changelog history for all Helm charts in the Grafana Community repository. It provides a user-friendly interface for browsing changes across different chart versions.

## Accessing the Changelog

End users can view the changelog at:  
**https://prometheus-community.github.io/helm-charts/changelog/**

## index.html Features

### 📊 Interactive Release History
- Displays all releases for each Helm chart
- Organized by chart and sorted by version/publication date
- Automatic filtering of CI and administrative commits

### 🎯 Chart Navigation
- Auto-detects all available charts in the repository
- Easy switching between different charts
- URL-based navigation with shareable links

### 🔗 External Integration
- **GitHub Links**: Direct links to releases and pull requests
- **ArtifactHub Integration**:
  - Template comparison views between versions
  - Values file comparison for configuration changes
  - Direct links to ArtifactHub package pages

### 🌓 Modern User Experience
- Responsive design (desktop & mobile optimized)
- Automatic dark mode support based on system preferences
- Manual theme toggle with localStorage persistence
- Clean, modern UI with GitHub-inspired styling

### 🔒 Security Features
- XSS protection through HTML sanitization
- Only safe domains allowed (GitHub, ArtifactHub)
- Input validation for repository parameters

## Technical Implementation

- **No external dependencies**: Pure vanilla JavaScript
- **GitHub API**: REST API v3 for fetching releases
- **Modern web standards**: HTML5, CSS3, responsive design
- **Performance optimized**: Pagination support for repositories with many releases

## How It Works

1. **Auto-Detection**: The app detects the GitHub organization from the page URL
2. **Release Fetching**: Queries GitHub API for repository releases
3. **Chart Extraction**: Parses release tags in `chart-name-version` format
4. **Dynamic UI**: Generates buttons for each chart and displays release notes
5. **Smart Filtering**: Removes CI-related changes and shows only relevant updates

## URL Parameters

- `?owner=organization&repo=repository` - Load specific repository
- `?chart=chart-name` - Display specific chart on page load
- All parameters are validated and sanitized for security

## Release Tag Format

For charts to appear in the changelog, releases must be tagged with:
```
chart-name-version
```

Example: `grafana-9.5.0`, `prometheus-mongodb-exporter-4.2.1`
