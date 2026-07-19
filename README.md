# DX Technical Documentation

This repository contains the technical documentation for DicetriX products, including API documentation and user manuals.

The documentation is written in Markdown and converted to versioned PDF files using Pandoc, LaTeX, YAML metadata, and GitHub Actions.

## Products

The repository currently contains documentation for:

- **DX CRM**
- **DX Travelz**

Each product may contain multiple document types, such as:

- API documentation
- User manuals
- Technical guides
- Installation guides

## Repository Structure

```text
DX-TECHNICAL-DOC/
├── .github/
│   └── workflows/
│       └── build-documents.yml
├── dist/
│   ├── dx-crm/
│   └── dx-travelz/
├── documents/
│   ├── dx-crm/
│   │   ├── api.md
│   │   └── usermanual.md
│   └── dx-travelz/
│       ├── api.md
│       └── usermanual.md
├── scripts/
│   └── build.sh
├── templates/
│   └── metadata.yml
├── documents.yml
├── Makefile
└── README.md
```

## Document Configuration

Document-specific metadata is maintained in `documents.yml`.

Example:

```yaml
products:
  dx-crm:
    name: "DicetriX CRM"

    documents:
      api:
        title: "DicetriX CRM API Documentation"
        source: "documents/dx-crm/api.md"
        version: "1.0.0"
        status: "approved"
        effective_date: "2026-07-19"
        owner: "DicetriX"
        output_name: "dx-crm-api"
```

The configuration defines:

| Parameter | Description |
|---|---|
| `title` | Document title |
| `source` | Path to the Markdown source file |
| `version` | Published document version |
| `status` | Document status, such as `draft` or `approved` |
| `effective_date` | Date on which the version becomes effective |
| `owner` | Document owner |
| `output_name` | Base name of the generated PDF |

Shared Pandoc and LaTeX settings are maintained in:

```text
templates/metadata.yml
```

## Document Versioning

Documents use semantic versioning:

```text
MAJOR.MINOR.PATCH
```

For example:

```text
1.2.3
```

The version components represent:

- **MAJOR**: substantial restructuring or incompatible changes
- **MINOR**: new sections, features, or meaningful content updates
- **PATCH**: typo corrections, formatting changes, or minor clarifications

Examples:

```text
1.0.0 → Initial approved release
1.1.0 → New API endpoint documentation
1.1.1 → Typographical or formatting correction
2.0.0 → Major restructuring or redesign
```

To publish a new version, update the relevant entry in `documents.yml`:

```yaml
version: "1.1.0"
effective_date: "2026-08-01"
```

The version change should be committed together with the corresponding Markdown changes.

## Local Build Requirements

The local build requires:

- Pandoc
- XeLaTeX
- `yq`
- GNU Make

### macOS

```bash
brew install pandoc
brew install --cask mactex-no-gui
brew install yq
```

After installing MacTeX, ensure the TeX binaries are available:

```bash
export PATH="/Library/TeX/texbin:$PATH"
```

### Ubuntu

```bash
sudo apt-get update

sudo apt-get install -y \
  pandoc \
  texlive-xetex \
  texlive-latex-extra \
  texlive-fonts-recommended \
  texlive-fonts-extra \
  make
```

Install `yq` separately:

```bash
sudo wget \
  https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
  -O /usr/local/bin/yq

sudo chmod +x /usr/local/bin/yq
```

## Building Documents

Make the build script executable:

```bash
chmod +x scripts/build.sh
```

### Build all documents

```bash
make build
```

Alternatively:

```bash
./scripts/build.sh all
```

### Build a specific document

Build the DX CRM API documentation:

```bash
make crm-api
```

Build the DX CRM user manual:

```bash
make crm-manual
```

Build the DX Travelz API documentation:

```bash
make travelz-api
```

Build the DX Travelz user manual:

```bash
make travelz-manual
```

A document can also be built directly:

```bash
./scripts/build.sh document dx-crm api
```

The command format is:

```text
./scripts/build.sh document <product> <document-type>
```

## Generated Documents

Generated PDF files are stored in the `dist` directory.

Example:

```text
dist/
└── dx-crm/
    ├── dx-crm-api-latest.pdf
    └── v1.1.0/
        └── dx-crm-api-v1.1.0.pdf
```

Two output forms are generated:

1. A version-specific PDF:

   ```text
   dx-crm-api-v1.1.0.pdf
   ```

2. A latest-version PDF:

   ```text
   dx-crm-api-latest.pdf
   ```

The version-specific file provides an auditable document history, while the latest file provides a stable path for users.

## Cleaning Generated Files

To remove all locally generated documents:

```bash
make clean
```

This removes the contents of the `dist` directory.

## GitHub Actions

The GitHub Actions workflow is defined in:

```text
.github/workflows/build-documents.yml
```

The workflow runs when relevant files are changed, including:

- Markdown documents
- YAML configuration files
- templates
- build scripts
- the Makefile
- the workflow itself

The workflow can also be run manually:

1. Open the repository on GitHub.
2. Select **Actions**.
3. Select **Build technical documents**.
4. Select **Run workflow**.

After the workflow completes, the generated PDFs are available under the **Artifacts** section of the workflow run.

## Adding a New Document

### 1. Create the Markdown file

For example:

```text
documents/dx-crm/installation-guide.md
```

### 2. Add the document configuration

Add the document under the corresponding product in `documents.yml`:

```yaml
installation-guide:
  title: "DicetriX CRM Installation Guide"
  source: "documents/dx-crm/installation-guide.md"
  version: "1.0.0"
  status: "draft"
  effective_date: "2026-07-19"
  owner: "DicetriX"
  output_name: "dx-crm-installation-guide"
```

The general build command will automatically include the new document:

```bash
make build
```

## Adding a New Product

Add a new product under `products` in `documents.yml`:

```yaml
products:
  dx-new-product:
    name: "DicetriX New Product"

    documents:
      usermanual:
        title: "DicetriX New Product User Manual"
        source: "documents/dx-new-product/usermanual.md"
        version: "1.0.0"
        status: "draft"
        effective_date: "2026-07-19"
        owner: "DicetriX"
        output_name: "dx-new-product-user-manual"
```

Create the corresponding source directory:

```text
documents/dx-new-product/
```

The build script will discover the product and document entries from `documents.yml`.

## Recommended Release Workflow

1. Update the Markdown document.
2. Update its version and effective date in `documents.yml`.
3. Build the document locally.
4. Review the generated PDF.
5. Commit the source and configuration changes.
6. Push the changes to GitHub.
7. Confirm that the GitHub Actions build succeeds.
8. Optionally create a Git tag for the release.

Example:

```bash
git add documents/dx-crm/api.md documents.yml
git commit -m "Release DX CRM API documentation v1.1.0"
git push origin main
```

Optional Git tag:

```bash
git tag docs/dx-crm-api/v1.1.0
git push origin docs/dx-crm-api/v1.1.0
```

## Document Status

Recommended status values are:

| Status | Meaning |
|---|---|
| `draft` | Document is under development |
| `review` | Document is awaiting review |
| `approved` | Document has been approved |
| `deprecated` | Document is no longer recommended |
| `archived` | Document is retained only for historical purposes |

## Contributing

When updating documentation:

- Use clear and consistent technical language.
- Keep headings and formatting consistent.
- Update the document version when published content changes.
- Update the effective date for approved releases.
- Build and review the PDF before submitting changes.
- Do not overwrite previously published version directories.
- Use descriptive commit messages.

## License

This repository and its documentation are proprietary to DicetriX unless otherwise stated.

Unauthorized copying, distribution, modification, or publication of the documentation is prohibited.
