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

## Relationships

- A **Supermarket Visit** happens at exactly one **Supermarket**
- A **Product Item** belongs to exactly one **Product Family**
- **On-the-fly Family Creation** may occur before saving a **Product Item**
- A **Product Family** is looked up by **Family Normalized Key** before creation
- **Reuse-first Family Matching** prevents creating multiple families for the same normalized meaning
- **Last-used Supermarket Default** pre-fills supermarket for the next Product Item capture
- **Capture Preferences** persist the default supermarket in local database settings
- If preferred supermarket is inactive, default falls back to the first active supermarket and updates preference
- Re-entering the same product in the same family and supermarket creates a new current price record and retires the previous current one

## Example dialogue

> **Dev:** "If I’m in Esclat and I add a new product with a family name that doesn’t exist, what happens?"
> **Domain expert:** "We create the **Product Family** on the fly, then save the **Product Item** under that family."

## Flagged ambiguities

- "anar al supermercat" could mean route optimization or price capture; resolved: here it means **Supermarket Visit** for quick price capture.
- "family name equality" was ambiguous (raw text vs normalized); resolved: matching uses **Family Normalized Key** and follows **Reuse-first Family Matching**.
- "quick add location" was open (new page vs existing page); resolved: first iteration lives in existing **Product Items** page.
