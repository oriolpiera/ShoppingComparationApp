# Shopping Comparison

This context defines the language for capturing supermarket product prices and comparing alternatives across stores.

## Language

**Supermarket Visit**:
A real-world trip to a specific supermarket where prices are captured.
_Avoid_: shopping run, session

**Product Family**:
A canonical category of Product Items that are substitutable for the same shopping need across supermarkets.
_Avoid_: broad category, group, type, non-substitutable products in one family

**Product Item**:
A concrete priced product captured in a supermarket and linked to one Product Family, optionally enriched with metadata such as brand.
_Avoid_: sku record, row

**Brand**:
Product Item metadata that helps identify and display a concrete product without defining the Product Family boundary by itself.
_Avoid_: brand-as-family, brand-only substitutability

**Measurement Unit**:
A normalized unit used to compare Product Items and Shopping Need Entries; internal quantities use base units for mass, volume, or count while the UI may display kg, g, L, ml, or units.
_Avoid_: free-text unit, kg/L-only model, mixing display units with comparison units

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
A shopping-list line that represents demand for one Product Family and a required quantity expressed in that family's shopping unit, without pinning a concrete Product Item.
_Avoid_: item-pinned shopping row, duplicated-family lines

**Shopping Unit**:
The unit used by a Product Family to express shopping-list need, independent from the package size of any specific Product Item.
_Avoid_: assuming shopping quantity means package count, mixing need quantity with product package size

**Package Quantity**:
The amount of Shopping Unit contained in one concrete Product Item, used to calculate how many whole items are needed to satisfy a Shopping Need Entry.
_Avoid_: fractional package purchases, unit-price-only optimization for packaged goods

**Purchase Mode**:
The way a Product Family is bought for shopping optimization: divisible by weight or volume, whole packaged items, or discrete pieces.
_Avoid_: treating all families as packages, treating all families as infinitely divisible

**Barcode Matches View**:
A Product Items scan-result view that lists current active Product Items matching a scanned barcode before any new capture.
_Avoid_: auto-pick without visibility, immediate edit-only flow

**Scanned Price Registration**:
Registering a scanned barcode price for a supermarket by creating a new current Product Item only when `price + quantity + unitType` changed.
_Avoid_: unconditional duplicate creation, in-place overwrite without historical rollover

**External Product Metadata**:
Optional product information from external catalogs, such as OpenFoodFacts, used to enrich a local Product Item without replacing Product Family as the app's comparison concept.
_Avoid_: external catalog as product source of truth, barcode-first product identity

**External Price Observation**:
A price from an external source, such as OpenPrices, that may inform comparison but remains separate from locally confirmed Product Items until explicitly accepted or confirmed.
_Avoid_: automatic Product Item import, untrusted current price

**External Price Review Status**:
The user's decision about whether an External Price Observation should be used for comparison: unreviewed, accepted for comparison, or discarded for comparison.
_Avoid_: treating every imported price equally, hiding trust decisions inside the optimizer

**OpenPrices Tag**:
A visible label shown when a comparison or optimized shopping result uses an accepted External Price Observation from OpenPrices.
_Avoid_: verbose trust warnings for accepted prices, indistinguishable local and external prices

**Local Price Confirmation**:
A user-verified supermarket price that creates or updates a local Product Item while preserving any related External Price Observation as source context.
_Avoid_: replacing local confirmation with external trust status, deleting source observations after verification

**External Store Mapping**:
An explicit association between an external store or location, such as an OpenPrices location, and a local Supermarket used for shopping optimization.
_Avoid_: auto-created supermarkets from external data, chain-name-only matching

**Fresh Product Item**:
A Product Item without barcode-based identity, captured by local name, Product Family, Supermarket, price, and measurement details.
_Avoid_: pseudo-barcode identity, external SKU assumptions for fresh products

**User-confirmed Family Mapping**:
An explicit association chosen by the user between external product metadata and a local Product Family, optionally aided by suggested clean family names.
_Avoid_: category-driven automatic family creation, unreviewed external taxonomy mapping

## Relationships

- A **Supermarket Visit** happens at exactly one **Supermarket**
- A **Product Item** belongs to exactly one **Product Family**
- Product Items in the same **Product Family** are substitutable for the same **Shopping Need Entry** according to the user's real buying intent
- Product attributes such as lactose-free, organic, or smoked should form separate **Product Families** when they change substitutability for the user
- **Brand** belongs to a **Product Item** and does not define a **Product Family** boundary by itself
- A **Product Item** uses a normalized **Measurement Unit** compatible with its Product Family's **Shopping Unit**
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
- A **Shopping Need Entry** stores only `ProductFamily` + quantity in the family's **Shopping Unit**; the concrete best `Product Item` is resolved dynamically
- A **Shopping Unit** is independent from Product Item package size; one family may compare items sold in 250 ml, 300 ml, or other package sizes
- **Package Quantity** determines how many whole Product Items are needed to satisfy a **Shopping Need Entry**
- A **Purchase Mode** determines whether shopping optimization uses divisible quantity, whole packages, or discrete pieces for a Product Family
- Shopping optimization compares whole Product Item counts for packaged families, not fractional package purchases
- Internal shopping-domain changes for **Measurement Unit**, **Shopping Unit**, **Package Quantity**, and **Purchase Mode** should be established before deeper OpenFoodFacts or OpenPrices integration
- First implementation slice should be domain-pure logic and tests before database or UI migration
- Adding a family already present in Shopping List merges into the same entry by increasing quantity (no duplicate lines)
- Shopping List add flows exist both from Product Family detail and from Shopping List `+`
- Shopping List family picker includes only active Product Families
- Shopping List quantity input is integer-only
- If a Shopping List family becomes inactive, the entry remains visible with inactive visual treatment and is excluded from optimized shopping grouping
- **Barcode Matches View** includes only Product Items where `isCurrentPrice = true` and `isActive = true`
- **External Product Metadata** may enrich a **Product Item** when a barcode exists, but **Product Family** remains the canonical comparison concept
- **User-confirmed Family Mapping** decides which **Product Family** external product metadata belongs to
- External metadata may suggest a clean Product Family name, brand, and package quantity, but the user confirms the Product Family boundary
- An **External Price Observation** does not automatically become a **Product Item**
- An **External Price Observation** may be accepted or discarded for comparison from its Product Family context
- Unreviewed **External Price Observations** may guide manual verification but are not trusted as locally confirmed Product Items
- Accepted OpenPrices observations may participate in comparison and optimized shopping results when shown with an **OpenPrices Tag**
- **Local Price Confirmation** creates or updates a local **Product Item** and does not delete the related **External Price Observation**
- **External Store Mapping** is required before an external store can participate as a local **Supermarket** in optimized shopping results
- A **Fresh Product Item** is identified locally by its Product Family, Supermarket, name, price, and measurement details rather than barcode or external SKU
- Scanned barcode lookup uses exact match after trimming surrounding whitespace
- **Scanned Price Registration** compares `price + quantity + unitType` in the selected supermarket to decide no-op vs new current Product Item
- If scanned registration is a no-op, UI feedback is explicit: "Price already current in this supermarket. No new Product Item created."

## Example dialogue

> **Dev:** "If I’m in Esclat and I add a new product with a family name that doesn’t exist, what happens?"
> **Domain expert:** "We create the **Product Family** on the fly, then save the **Product Item** under that family."

## Flagged ambiguities

- "anar al supermercat" could mean route optimization or price capture; resolved: here it means **Supermarket Visit** for quick price capture.
- "family name equality" was ambiguous (raw text vs normalized); resolved: matching uses **Family Normalized Key** and follows **Reuse-first Family Matching**.
- "quick add location" was open (new page vs existing page); resolved: first iteration lives in existing **Product Items** page.
- "unityType" vs "unitType" naming was ambiguous; earlier resolved as **Unit Type**, now superseded by **Measurement Unit** because shopping optimization requires mass, volume, and count units beyond kg/L.
