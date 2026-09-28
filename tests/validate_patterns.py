#!/usr/bin/env python3
"""
Validate cloud-patterns data structure and assets.

Prevents regressions by ensuring:
- patterns.json has valid schema
- All referenced diagram files exist
- All pattern IDs are unique
- Required fields are present
"""

import json
import sys
from pathlib import Path

def load_patterns():
    """Load and parse patterns.json."""
    patterns_file = Path(__file__).parent.parent / "data" / "patterns.json"
    with open(patterns_file) as f:
        return json.load(f)

def validate_schema(data):
    """Validate top-level schema."""
    required_keys = {"version", "metadata", "patterns"}
    if not all(key in data for key in required_keys):
        raise AssertionError(f"Missing required keys: {required_keys - set(data.keys())}")

    if not isinstance(data["patterns"], list):
        raise AssertionError("'patterns' must be a list")

    print(f"✓ Top-level schema valid")

def validate_pattern(pattern, index):
    """Validate individual pattern structure."""
    required_fields = {
        "id", "title", "slug", "category", "status",
        "concerns", "problem", "decision",
        "use_when", "avoid_when", "tradeoffs",
        "conceptual_components", "diagram",
        "design_decisions"
    }

    missing = required_fields - set(pattern.keys())
    if missing:
        raise AssertionError(f"Pattern {index} '{pattern.get('id', 'unknown')}' missing fields: {missing}")

    # Validate ID and slug
    if not isinstance(pattern["id"], str) or not pattern["id"]:
        raise AssertionError(f"Pattern {index}: id must be non-empty string")

    if not isinstance(pattern["slug"], str) or not pattern["slug"]:
        raise AssertionError(f"Pattern {index}: slug must be non-empty string")

    # Validate status
    valid_statuses = {"implemented", "in-progress", "queued"}
    if pattern["status"] not in valid_statuses:
        raise AssertionError(f"Pattern {index} '{pattern['id']}': invalid status '{pattern['status']}'")

    # Validate arrays
    if not isinstance(pattern["concerns"], list) or not pattern["concerns"]:
        raise AssertionError(f"Pattern {index} '{pattern['id']}': concerns must be non-empty list")

    if not isinstance(pattern["use_when"], list) or not pattern["use_when"]:
        raise AssertionError(f"Pattern {index} '{pattern['id']}': use_when must be non-empty list")

    if not isinstance(pattern["avoid_when"], list) or not pattern["avoid_when"]:
        raise AssertionError(f"Pattern {index} '{pattern['id']}': avoid_when must be non-empty list")

    if not isinstance(pattern["tradeoffs"], list) or not pattern["tradeoffs"]:
        raise AssertionError(f"Pattern {index} '{pattern['id']}': tradeoffs must be non-empty list")

    # Validate tradeoff structure
    for i, tradeoff in enumerate(pattern["tradeoffs"]):
        if "benefit" not in tradeoff or "cost" not in tradeoff:
            raise AssertionError(f"Pattern {index} '{pattern['id']}' tradeoff {i}: must have 'benefit' and 'cost'")

    # Validate components
    if not isinstance(pattern["conceptual_components"], list) or not pattern["conceptual_components"]:
        raise AssertionError(f"Pattern {index} '{pattern['id']}': conceptual_components must be non-empty list")

    for i, comp in enumerate(pattern["conceptual_components"]):
        required_comp_fields = {"id", "label", "kind", "description"}
        if not all(f in comp for f in required_comp_fields):
            raise AssertionError(f"Pattern {index} '{pattern['id']}' component {i}: missing required fields")

    # Validate design decisions
    if not isinstance(pattern["design_decisions"], list) or not pattern["design_decisions"]:
        raise AssertionError(f"Pattern {index} '{pattern['id']}': design_decisions must be non-empty list")

    for i, decision in enumerate(pattern["design_decisions"]):
        if "decision" not in decision or "rationale" not in decision:
            raise AssertionError(f"Pattern {index} '{pattern['id']}' decision {i}: must have 'decision' and 'rationale'")

    # Validate diagram
    if "diagram" in pattern and pattern["diagram"]:
        diagram = pattern["diagram"]
        if "kind" not in diagram or diagram["kind"] != "original_svg":
            raise AssertionError(f"Pattern {index} '{pattern['id']}': diagram kind must be 'original_svg'")

        if "file" not in diagram:
            raise AssertionError(f"Pattern {index} '{pattern['id']}': diagram must have 'file' path")

    print(f"✓ Pattern {index}: '{pattern['id']}' schema valid")

def validate_diagram_files(data):
    """Check that all referenced diagram files exist."""
    base_path = Path(__file__).parent.parent

    for i, pattern in enumerate(data["patterns"]):
        if "diagram" in pattern and pattern["diagram"] and "file" in pattern["diagram"]:
            diagram_file = base_path / pattern["diagram"]["file"]
            if not diagram_file.exists():
                raise AssertionError(f"Pattern {i} '{pattern['id']}': diagram file not found: {pattern['diagram']['file']}")

            if not diagram_file.suffix == ".svg":
                raise AssertionError(f"Pattern {i} '{pattern['id']}': diagram must be SVG, got {diagram_file.suffix}")

            print(f"✓ Pattern {i} '{pattern['id']}': diagram file exists")

def validate_unique_ids(data):
    """Ensure all pattern IDs are unique."""
    ids = [p["id"] for p in data["patterns"]]
    duplicates = [id for id in ids if ids.count(id) > 1]

    if duplicates:
        raise AssertionError(f"Duplicate pattern IDs: {set(duplicates)}")

    print(f"✓ All {len(ids)} pattern IDs are unique")

def main():
    """Run all validations."""
    try:
        print("Loading patterns.json...")
        data = load_patterns()

        print("\nValidating schema...")
        validate_schema(data)

        print("\nValidating individual patterns...")
        for i, pattern in enumerate(data["patterns"]):
            validate_pattern(pattern, i)

        print("\nValidating diagram files...")
        validate_diagram_files(data)

        print("\nValidating uniqueness...")
        validate_unique_ids(data)

        print(f"\n✅ All validations passed! ({len(data['patterns'])} patterns)")
        return 0

    except (json.JSONDecodeError, FileNotFoundError, AssertionError) as e:
        print(f"\n❌ Validation failed: {e}", file=sys.stderr)
        return 1

if __name__ == "__main__":
    sys.exit(main())
