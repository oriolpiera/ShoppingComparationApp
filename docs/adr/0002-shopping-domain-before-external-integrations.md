# Build the shopping domain before deep external integrations

The app will first strengthen its own shopping domain before adding deeper OpenFoodFacts or OpenPrices integration. This order is deliberate: Product Family remains the canonical comparison concept, Product Items may be enriched by external metadata, and OpenPrices prices remain External Price Observations until reviewed. Building external integrations before fixing the internal model would force barcode-centric and kg/L-only shortcuts into the optimizer.

Planned order:

1. Model normalized measurement units so mass, volume, and count can be compared internally while the UI displays human units such as kg, g, L, ml, or units.
2. Add Product Family shopping semantics: Shopping Unit, Purchase Mode, and Package Quantity so shopping needs are separate from concrete Product Item package sizes.
3. Update shopping optimization to handle divisible weighted goods, discrete pieces, and whole packaged items instead of relying only on unit price.
4. Improve Product Family/Product Item capture so fresh products without barcodes and packaged products with different sizes can be recorded consistently.
5. Use OpenFoodFacts as External Product Metadata for barcode products, suggesting clean names, brand, and package quantity while keeping Product Family mapping user-confirmed.
6. Add OpenPrices as External Price Observations with review status: unreviewed, accepted for comparison, or discarded for comparison.
7. Allow accepted OpenPrices observations to participate in comparison and optimized shopping results with a visible OpenPrices tag.
8. Add explicit External Store Mapping before external stores can participate as local Supermarkets in optimized shopping results.
9. When a user verifies an external price in-store, create or update a local Product Item while preserving the related External Price Observation as source context.
