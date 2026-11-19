# DriveEase Car Rental Management Database — Phase 3

## Purpose
Phase 3 extends the DriveEase relational database with PostgreSQL table inheritance for vehicle subtypes, JSONB vehicle specifications, and semantic search using pgvector.

## Folder contents
- `Design_Plan/`: Phase 3 design plan and supporting design notes.
- `Diagrams/`: Mermaid source for the UML class diagram and data pipeline diagram.
- `SQL_Scripts/`: Part D combined query and the team's Part A, B, and C SQL scripts.
- `Embeddings/`: Embedding-generation scripts, raw text inputs, and generated SQL load files.
- `Query_Results/`: Screenshots, EXPLAIN output, evaluation tables, and query results.
- `Technical_Report/`: Final technical report.

## Setup and execution order
Run scripts in the target DriveEase database using pgAdmin 4 Query Tool or another PostgreSQL client. Confirm the database backup is current before running scripts.

1. Run the Phase 2 relational schema and data-loading scripts first.
2. Enable pgvector: `CREATE EXTENSION IF NOT EXISTS vector;`
3. Run the Part A object-oriented hierarchy script. This creates/updates the vehicle subtype tables, integrity logic, and related view/functions.
4. Run the Part B JSONB script. This adds/validates the `vehicle.specifications` JSONB data and creates the JSONB index/catalog objects.
5. Generate and run the vehicle-vector SQL load file to populate `vehicle_vectors` and create its HNSW index.
6. Generate and run the customer-search SQL load file to populate `searches` and create its HNSW index.
7. Run the Part C search scripts and evaluation queries.
8. Run `SQL_Scripts/part_d_combined_query.sql` for Part D.

The order above assumes the Part A and Part B scripts are the team's final schema scripts. Adjust only if the actual script dependencies require it.

## Embedding generation
- Model: `sentence-transformers/all-MiniLM-L6-v2`
- Model revision: `1110a243fdf4706b3f48f1d95db1a4f5529b4d41`
- Dimensions: 384
- Normalization: embeddings are generated with `normalize_embeddings=True`.
- Runtime: local Python environment, launched from VS Code according to the generation script comments.
- Vehicle input: `vehicles_ids_with_descriptions.csv`, with `id` and `description` columns.
- Customer input: `customer search options.txt`, one prompt per line (16 prompts in the supplied input).
- Generator: `vector_maker.py` for vehicle descriptions. Include the customer-search generator script in `Embeddings/` as well.

To regenerate: install the dependencies, place the input files beside the relevant script/notebook, run the generator, then execute the generated SQL files in PostgreSQL. The vehicle generator writes `my_sql/vehicle_description_vectors.sql`; the customer-search generator writes `my_sql/vehicle_searches.sql`

## Dataset source, licence, and size
The vehicle descriptions are synthetic descriptions generated from the DriveEase vehicle data. The supplied embedding input contains 150 vehicle descriptions. The customer search input contains 16 prompts.

## Dependencies and environment
- PostgreSQL
- pgvector
- Python: 3.10 or newer
- Python packages: `sentence-transformers`, `numpy`, `pandas`
- Embedding model files may be downloaded by Sentence Transformers on first run. Internet access may be required for the initial model download.

## Credentials
Do not commit passwords, API keys, or database connection strings. Supply credentials through local environment variables or a local configuration file excluded by `.gitignore`. For example, use a local `.env` file and add `.env` to `.gitignore`. Commit only a `.env.example` containing placeholder variable names, never real values.

## Important data-integrity note
The `vehicle_vectors.id` column is intended to match `vehicle.vehicle_id`, but the vector table definition shown in the generator does not declare a foreign key. Verify that every vector ID matches a vehicle ID before relying on joins. Do not add a foreign key until the IDs have been checked.

## Large files
If generated SQL files containing embeddings are too large for GitHub, keep the generation script and raw text inputs in the repository and provide a download/access instruction for the generated SQL file. Do not commit credentials or private data.
