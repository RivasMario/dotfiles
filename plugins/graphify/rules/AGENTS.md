# Graphify Rules

When answering questions about codebase architecture, file relationships, or component dependencies:
- Check if `graphify-out/` or `graphify-out/graph.json` exists in the repository.
- If it exists, prefer querying the graph using `graphify query` or inspecting `graphify-out/GRAPH_REPORT.md` before scanning raw files.
- To map, update, or build the knowledge graph of this repository, run `/graphify .`.
