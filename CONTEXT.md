# Shopping Comparison

This context defines the language for capturing supermarket product prices and comparing alternatives across stores.

## Language

**Supermarket Visit**:
A real-world trip to a specific supermarket where prices are captured.
_Avoid_: shopping run, session

**Product Family**:
A canonical category used to compare equivalent products across supermarkets.
_Avoid_: group, type

**Product Item**:
A concrete priced product captured in a supermarket and linked to one Product Family.
_Avoid_: sku record, row

**Unit Type**:
The measurement unit used to express quantity and unit price for a Product Item; allowed values are `kg` and `L`.
_Avoid_: unityType, free-text unit

**On-the-fly Family Creation**:
Creating a new Product Family during Product Item capture when no matching family exists.
_Avoid_: preseed-only families

**Family Normalized Key**:
A search key derived from a family name using case-folding, accent removal, and whitespace normalization.
_Avoid_: raw name matching

**Reuse-first Family Matching**:
When a normalized key already exists, always reuse that Product Family and postpone naming cleanup.
_Avoid_: duplicate family creation

**Last-used Supermarket Default**:
Quick product capture preselects the same supermarket used in the previous saved Product Item.
_Avoid_: forcing supermarket reselection every time

**Capture Preferences**:
Persistent local settings that influence fast capture defaults across app restarts.
_Avoid_: session-only UI state

**Family Comparison Row**:
A row in Product Family Detail Comparison showing `Supermarket`, `Product name`, `Price`, `Quantity/Unit`, and `Unit price`.
_Avoid_: overloaded rows with unrelated metadata

**Family Comparison Summary**:
A header summary in Product Family details showing `Current active items count` and `Best unit price` before the comparison rows.
_Avoid_: burying key comparison context only inside row scanning

**Shopping Need Entry**:
A shopping-list line that represents demand for one Product Family and a required integer quantity, without pinning a concrete Product Item.
_Avoid_: item-pinned shopping row, duplicated-family lines

## Relationships

- A **Supermarket Visit** happens at exactly one **Supermarket**
- A **Product Item** belongs to exactly one **Product Family**
- A **Product Item** uses exactly one **Unit Type** (`kg` or `L`) for quantity and unit-price display
- **On-the-fly Family Creation** may occur before saving a **Product Item**
- A **Product Family** is looked up by **Family Normalized Key** before creation
- **Reuse-first Family Matching** prevents creating multiple families for the same normalized meaning
- **Last-used Supermarket Default** pre-fills supermarket for the next Product Item capture
- **Capture Preferences** persist the default supermarket in local database settings
- If preferred supermarket is inactive, default falls back to the first active supermarket and updates preference
- Re-entering the same product in the same family and supermarket creates a new current price record and retires the previous current one
- **Product Family Detail Comparison** is shown inside the existing Product Family details page
- **Product Family Detail Comparison** lists all Product Items of that family where `isCurrentPrice = true` and `isActive = true`
- Historical Product Items (`isCurrentPrice = false`) are excluded from Product Family Detail Comparison
- **Product Family Detail Comparison** is a flat list sorted by unit price ascending to support supermarket comparison
- If unit price ties, comparison order breaks ties by total price ascending, then supermarket name ascending
- **Family Comparison Summary** shows best unit price as numeric value only (no winner supermarket annotation)
- If a family has no current active Product Items, the detail view shows an explicit empty state message
- Tapping a **Family Comparison Row** opens Product Item details
- Editing from Product Item details opened via comparison follows the standard full Product Item edit flow
- Product Family Detail Comparison remains visible for inactive families and keeps the same current+active Product Item filter
- Inactivating a Product Family with active Product Items (`isActive = true`, regardless of `isCurrentPrice`) should show a warning including active-item count before confirmation
- Warning copy should be explicit: "This family has X active Product Items. Inactivating it may hide it from active family lists."
- After warning confirmation, a second decision modal lets the user choose whether to keep active Product Items as-is or inactivate them all
- The second decision modal has no default selection; users must choose explicitly
- Second decision modal actions are labeled `Keep active items` and `Inactivate all active items`
- Canceling or dismissing the second decision modal aborts family inactivation with no data changes
- Issue scope for Product Family detail includes both comparison view and family-inactivation warning behavior
- UI labels for this feature should use the canonical term `Product Items` instead of `Products`
- If a comparison row references an inactive or missing supermarket, keep row visible and show an `inactive supermarket` badge
- Family Comparison Summary count includes all current active Product Items even when supermarket reference is inactive or missing
- Issue #23 includes widget/UI tests for empty-state rendering, comparison sort order, and two-step family inactivation warning flow
- A **Shopping Need Entry** stores only `ProductFamily` + integer quantity; the concrete best `Product Item` is resolved dynamically
- Adding a family already present in Shopping List merges into the same entry by increasing quantity (no duplicate lines)
- Shopping List add flows exist both from Product Family detail and from Shopping List `+`
- Shopping List family picker includes only active Product Families
- Shopping List quantity input is integer-only
- If a Shopping List family becomes inactive, the entry remains visible with inactive visual treatment and is excluded from optimized shopping grouping

## Example dialogue

> **Dev:** "If I’m in Esclat and I add a new product with a family name that doesn’t exist, what happens?"
> **Domain expert:** "We create the **Product Family** on the fly, then save the **Product Item** under that family."

## Flagged ambiguities

- "anar al supermercat" could mean route optimization or price capture; resolved: here it means **Supermarket Visit** for quick price capture.
- "family name equality" was ambiguous (raw text vs normalized); resolved: matching uses **Family Normalized Key** and follows **Reuse-first Family Matching**.
- "quick add location" was open (new page vs existing page); resolved: first iteration lives in existing **Product Items** page.
- "unityType" vs "unitType" naming was ambiguous; resolved canonical term: **Unit Type**.
