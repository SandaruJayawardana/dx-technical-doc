#!/usr/bin/env python3

from pathlib import Path
from typing import Any

import yaml


ROOT = Path(__file__).resolve().parent.parent
CONFIG_PATH = ROOT / "documents.yml"
OUTPUT_PATH = ROOT / "documents" / "versions.md"


def load_configuration() -> dict[str, Any]:
    if not CONFIG_PATH.exists():
        raise FileNotFoundError(f"Configuration not found: {CONFIG_PATH}")

    with CONFIG_PATH.open("r", encoding="utf-8") as file:
        configuration = yaml.safe_load(file)

    if not isinstance(configuration, dict):
        raise ValueError("documents.yml must contain a YAML mapping.")

    return configuration


def escape_table_value(value: object) -> str:
    return str(value).replace("|", "\\|")


def generate_version_page(configuration: dict[str, Any]) -> str:
    lines = [
        "# Document Versions",
        "",
        "This page is generated automatically from `documents.yml`.",
        "",
        "| Product | Document | Version | Status | Effective date | PDF |",
        "|---|---|---:|---|---|---|",
    ]

    products = configuration.get("products", {})

    for product_id, product in products.items():
        product_name = product.get("name", product_id)
        documents = product.get("documents", {})

        for document_id, document in documents.items():
            title = document.get("title", document_id)
            version = document.get("version", "Unspecified")
            status = document.get("status", "Unspecified")
            effective_date = document.get("effective_date", "Unspecified")
            output_name = document.get("output_name", document_id)

            latest_pdf = (
                f"downloads/{product_id}/"
                f"{output_name}-latest.pdf"
            )

            versioned_pdf = (
                f"downloads/{product_id}/v{version}/"
                f"{output_name}-v{version}.pdf"
            )

            pdf_links = (
                f"[Latest]({latest_pdf}) · "
                f"[Version {version}]({versioned_pdf})"
            )

            lines.append(
                "| "
                + " | ".join(
                    [
                        escape_table_value(product_name),
                        escape_table_value(title),
                        escape_table_value(version),
                        escape_table_value(str(status).title()),
                        escape_table_value(effective_date),
                        pdf_links,
                    ]
                )
                + " |"
            )

    lines.extend(
        [
            "",
            "## Versioning Convention",
            "",
            "Documents use semantic versioning:",
            "",
            "```text",
            "MAJOR.MINOR.PATCH",
            "```",
            "",
            "- **MAJOR**: substantial restructuring or incompatible changes",
            "- **MINOR**: meaningful content additions or updates",
            "- **PATCH**: corrections, formatting changes, or clarifications",
            "",
            "The version displayed on this page is controlled by "
            "`documents.yml`.",
            "",
        ]
    )

    return "\n".join(lines)


def main() -> None:
    configuration = load_configuration()
    content = generate_version_page(configuration)

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_PATH.write_text(content, encoding="utf-8")

    print(f"Generated {OUTPUT_PATH.relative_to(ROOT)}")


if __name__ == "__main__":
    main()