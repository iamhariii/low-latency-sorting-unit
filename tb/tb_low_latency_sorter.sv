`timescale 1ns/1ps
module tb_low_latency_sorter;
    localparam integer DATA_WIDTH = 16;
    logic clk = 0;
    logic rst = 1;
    logic in_valid = 0;
    logic [8*DATA_WIDTH-1:0] in_data = '0;
    logic out_valid;
    logic [8*DATA_WIDTH-1:0] out_data;

    low_latency_sorter #(.DATA_WIDTH(DATA_WIDTH)) dut (
        .clk, .rst, .in_valid, .in_data, .out_valid, .out_data
    );

    always #5 clk = ~clk;

    task automatic send_and_check(input logic [15:0] values [0:7]);
        logic [15:0] expected [0:7];
        logic [15:0] temp;
        integer i, j;
        begin
            for (i = 0; i < 8; i++) begin
                expected[i] = values[i];
                in_data[i*DATA_WIDTH +: DATA_WIDTH] = values[i];
            end
            // Reference sort (bubble sort) for simulation checking only.
            for (i = 0; i < 8; i++)
                for (j = 0; j < 7-i; j++)
                    if (expected[j] > expected[j+1]) begin
                        temp = expected[j];
                        expected[j] = expected[j+1];
                        expected[j+1] = temp;
                    end
            in_valid = 1;
            @(posedge clk);
            #1;
            if (!out_valid) $fatal(1, "out_valid was not asserted");
            for (i = 0; i < 8; i++) begin
                if (out_data[i*DATA_WIDTH +: DATA_WIDTH] !== expected[i])
                    $fatal(1, "Mismatch at element %0d: got %0d expected %0d",
                           i, out_data[i*DATA_WIDTH +: DATA_WIDTH], expected[i]);
            end
            in_valid = 0;
            @(posedge clk);
            #1;
        end
    endtask

    initial begin : test_sequence
        logic [15:0] v [0:7];
        integer t, i;
        repeat (2) @(posedge clk);
        rst = 0;

        v[0]=8; v[1]=7; v[2]=6; v[3]=5;
        v[4]=4; v[5]=3; v[6]=2; v[7]=1;
        send_and_check(v);

        v[0]=0; v[1]=65535; v[2]=42; v[3]=42;
        v[4]=1; v[5]=32768; v[6]=9; v[7]=2;
        send_and_check(v);

        v[0]=11; v[1]=11; v[2]=11; v[3]=11;
        v[4]=11; v[5]=11; v[6]=11; v[7]=11;
        send_and_check(v);

        for (t = 0; t < 200; t++) begin
            for (i = 0; i < 8; i++) v[i] = $urandom;
            send_and_check(v);
        end

        $display("PASS: directed and 200 randomized sorting tests completed.");
        $finish;
    end
endmodule
