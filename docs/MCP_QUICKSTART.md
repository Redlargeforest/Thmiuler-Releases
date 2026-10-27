# Thmiuler MCP quick start

Thmiuler exposes local engineering tools to an MCP client over stdio. The client supplies the AI model and orchestrates tool calls; Thmiuler supplies the real component catalog, checked model operations, solver execution, and recorded results.

## 1 Install the complete application

Follow the [installation guide](INSTALLATION.md). The normal installation path is `C:\Thmiuler`. The root `THMIULER-MCP.exe` is the supported launch entry point; it relies on the adjacent application folders.

## 2 Register the local server

Add the following to your MCP client's server settings. If the client provides a form instead of JSON, select a local stdio server and enter the same executable path.

```json
{
  "mcpServers": {
    "thmiuler": {
      "command": "C:\\Thmiuler\\THMIULER-MCP.exe"
    }
  }
}
```

A copy is available in [examples/mcp-client.json](../examples/mcp-client.json). Change only the path to match your installation. Reconnect or refresh the client's tool catalog after an application update. Do not configure this executable as a public HTTP service.

## 3 Confirm a read only connection

Ask the client to call `thmiuler_status`, then read the project context without editing it. A successful response identifies the application and available project or simulation state. The MCP entry point can start the desktop application when required.

> Check the connection, list open workspaces, and describe the current model. Do not open another project, edit the model, discard a draft, or save anything.

Use the returned workspace identities to target the intended model. If another unconfirmed draft exists, ask its owner how to proceed.

## 4 Build from actual component interfaces

1. Define the engineering task, quantities, units, constraints, system boundary, and simplifying assumptions.
2. Search with `thmiuler_search_components`. Read the returned component details and identities; do not invent port names or parameter keys.
3. Inspect physical and signal interfaces, working-fluid requirements, and connectivity. Preserve the current component identity and fingerprint when requested by the tool.
4. Read `thmiuler_get_modeling_schema` and the supplied modeling examples. Assemble a candidate plan using the actual schema.
5. Use `thmiuler_validate_modeling_plan` for a read only graph check. After correcting errors, stage a reversible draft with `thmiuler_stage_modeling_plan`.
6. Inspect the draft on the real canvas. Applying it with `thmiuler_apply_draft` requires explicit user confirmation; saving or opening files and creating new components have their own confirmation requirements.

A passed connection check is evidence about interface and structural consistency. Review the equations, boundary conditions, load assumptions, and parameter sources before treating the model as an engineering representation.

## 5 Run and explain the evidence

Before computing, state what stays fixed, what will change, and what the governing principle predicts. Check the project, run the simulation, and read its actual status and diagnostics. Keep the returned workspace and run identities with the results.

- Use `thmiuler_get_results` for bounded time-series retrieval.
- Use `thmiuler_analyze_results` for statistics over all retained samples; a downsampled curve alone is insufficient for quantitative peak claims.
- Use `thmiuler_get_plot_image` for a native result plot.
- Explain how the result answers the original engineering question, where it differs from the prediction, and which assumptions still need validation.

A final value is not proof of monotonicity or stability. An educational example is not a certified equipment or safety assessment.

## 6 Create and deliver a runtime panel

Read the panel schema and current layout, including the actual variable bindings and layout revision. Add controls with `thmiuler_update_panel_layout`, preserving revision checks. Only variables marked writable can serve as runtime inputs.

Open and start a panel preview with `thmiuler_control_panel_preview`. Confirm that displayed outputs have actual samples. A panel design image uses design values and is not simulation evidence. Close and reopen a preview after changing the underlying model so that the preview matches the latest revision.

For supported models, `thmiuler_export_panel_exe` packages the model and panel into a Windows EXE after explicit authorization. Test the resulting artifact on the intended target Windows system. Exporting with the normal Qt6 runtime does not establish Windows 7 compatibility. Bundled engineering recipes are starting points; they do not mean that a model or exported application has already been generated on your computer.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| The client cannot start the server | Confirm the absolute executable path and keep the complete installed folder structure. |
| The client shows an old tool list | Reconnect the MCP server or refresh the client's cached tools. |
| A port or component is rejected | Re-read the current catalog entry and exact interfaces; follow the returned diagnostic rather than guessing a replacement. |
| A result is empty or belongs to another model | Verify the workspace, run identity, solver status, recorded variables, and diagnostic log. |
| The panel shows values before a run | Distinguish design defaults from preview outputs with actual samples. |

Additional bundled reference: `resources/mcp/README_CN.md` in the installed application. Product information: [official website](https://thmiuler.com.cn/).
