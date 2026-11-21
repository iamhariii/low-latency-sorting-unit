# Low-Latency Sorting Unit — Artix-7 / Vivado

A small RTL project implementing an **8-element unsigned sorter** using a bitonic sorting network.

## Features

- 8 parallel input values, each `DATA_WIDTH` bits (default: 16).
- Ascending unsigned sort.
- Six compare/exchange network stages (24 compare/exchange operations).
- Registered output: one clock edge from input sampling to `out_valid`.
- One vector per clock throughput when `in_valid` is asserted on consecutive cycles.
- Synchronous, active-high reset.
- Self-checking SystemVerilog testbench with directed and randomized tests.

## Interface

`in_data` is a packed vector. Element 0 occupies the least-significant `DATA_WIDTH` bits:

```systemverilog
in_data[i*DATA_WIDTH +: DATA_WIDTH]
```

All eight values are sampled on a rising edge when `in_valid=1`. The sorted result appears in `out_data` and `out_valid` is asserted after that same edge. There is no ready/backpressure signal; the design accepts a new vector every clock.

## Files

- `rtl/low_latency_sorter.sv` — synthesizable sorter RTL.
- `tb/tb_low_latency_sorter.sv` — self-checking simulation testbench.
- `constraints/artix7_template.xdc` — intentionally incomplete timing/I/O template.
- `scripts/create_project.tcl` — creates a Vivado project.
- `.gitignore` — excludes generated Vivado outputs.

## Open in Xilinx Vivado

1. Extract the ZIP.
2. Open the Vivado Tcl Console in the extracted folder.
3. Run:

   ```tcl
   source scripts/create_project.tcl
   ```

4. If your exact Artix-7 part differs from the default, run the script in batch mode with your part number, or edit `part_name` in the Tcl script.
5. In **Simulation**, run `tb_low_latency_sorter`.
6. Before synthesis/implementation, set the exact FPGA part and add the correct board-specific clock and I/O pin constraints.

Default Tcl part is `xc7a35tcpg236-1` as an example only. Your Artix-7 board may use a different device/package/speed grade. Check the FPGA marking or board master XDC.

## GitHub

```bash
git init
git add .
git commit -m "Add low-latency FPGA sorting unit"
git branch -M main
git remote add origin https://github.com/<your-username>/<your-repository>.git
git push -u origin main
```

## Important design notes

- This implementation sorts **unsigned** values. For signed two's-complement sorting, change the comparison logic to signed comparisons and use signed element declarations/casts.
- The combinational network has six compare/exchange levels followed by an output register. The achievable clock frequency depends on the selected Artix-7 device, speed grade, synthesis, placement, and routing.
- "Low latency" is a design goal, not a guaranteed MHz/timing result. Confirm timing in Vivado with synthesis and implementation reports.
- The XDC contains no fabricated pin assignments. Use the official master XDC for your exact development board.
