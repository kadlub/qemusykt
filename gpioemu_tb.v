`timescale 1ns/1ps

module gpioemu_tb;

    reg n_reset = 1;
    reg [15:0] saddress = 0;
    reg srd = 0;
    reg swr = 0;
    reg [31:0] sdata_in = 0;
    // wire [31:0] sdata_out = 0;
    reg [31:0] gpio_in = 0;
    reg gpio_latch = 0;
    // wire [31:0] gpio_out = 0;
    reg clk = 0;
    wire [31:0] gpio_in_s_insp = 0;  // na potrzeby debuga
    wire [31:0] sdata_out_s = 0;




    integer i;

    initial begin
		$dumpfile("gpioemu.vcd");
		$dumpvars(0, gpioemu_tb);
		clk = 0;
	end


    always #1 clk <= ~clk;


    // Reset sequence
    initial begin
        n_reset = 0;
        n_reset = 1;
    end

    initial begin


        // Sprawdzenie: 2 * 7 = 14

        #5 sdata_in = 24'h2;
        #5 saddress = 16'h1D8;
        #5 swr = 1;    // początek operacji zapisu
        #5 swr = 0;    // koniec operacji zapisu

        #5 sdata_in = 24'h7;
        #5 saddress = 16'h1E0;
        #5 swr = 1;
        #5 swr = 0;

        #5 saddress = 16'h1E8; // oczekiwany wynik: E  (W)
        #5 srd = 1;
        #5 srd = 0;

        #5 saddress = 16'h1F0; // oczekiwany wynik: 3   (L)
        #5 srd = 1;
        #5 srd = 0;

        #5 saddress = 16'h1F8; // oczekiwany wynik: 0   (B)
        #5 srd = 1;
        #5 srd = 0;


        // Sprawdzenie: 0 * 13 = 0


        #5 sdata_in = 24'h0;
        #5 saddress = 16'h1D8;
        #5 swr = 1;    // początek operacji zapisu
        #5 swr = 0;    // koniec operacji zapisu

        #5 sdata_in = 24'hD;
        #5 saddress = 16'h1E0;
        #5 swr = 1;
        #5 swr = 0;

        #5 saddress = 16'h1E8; // oczekiwany wynik: 0  (W)
        #5 srd = 1;
        #5 srd = 0;

        #5 saddress = 16'h1F0; // oczekiwany wynik: 0   (L)
        #5 srd = 1;
        #5 srd = 0;

        #5 saddress = 16'h1F8; // oczekiwany wynik: 0   (B)
        #5 srd = 1;
        #5 srd = 0;


        // Sprawdzenie: 9 * 3 = 27


        #5 sdata_in = 24'h9;
        #5 saddress = 16'h1D8;
        #5 swr = 1;    // początek operacji zapisu
        #5 swr = 0;    // koniec operacji zapisu

        #5 sdata_in = 24'h3;
        #5 saddress = 16'h1E0;
        #5 swr = 1;
        #5 swr = 0;

        #5 saddress = 16'h1E8; // oczekiwany wynik: 1B  (W)
        #5 srd = 1;
        #5 srd = 0;

        #5 saddress = 16'h1F0; // oczekiwany wynik: 4   (L)
        #5 srd = 1;
        #5 srd = 0;

        #5 saddress = 16'h1F8; // oczekiwany wynik: 0   (B)
        #5 srd = 1;
        #5 srd = 0;


        // Sprawdzenie: 199 * 199 = 39 601


        #5 sdata_in = 24'hC7;
        #5 saddress = 16'h1D8;
        #5 swr = 1;    // początek operacji zapisu
        #5 swr = 0;    // koniec operacji zapisu

        #5 sdata_in = 24'hC7;
        #5 saddress = 16'h1E0;
        #5 swr = 1;
        #5 swr = 0;

        #5 saddress = 16'h1E8; // oczekiwany wynik: 9AB1  (W)
        #5 srd = 1;
        #5 srd = 0;

        #5 saddress = 16'h1F0; // oczekiwany wynik: 8   (L)
        #5 srd = 1;
        #5 srd = 0;

        #5 saddress = 16'h1F8; // oczekiwany wynik: 0   (B)
        #5 srd = 1;
        #5 srd = 0;

                // Sprawdzenie: 305 * 289 = 88 145


        #5 sdata_in = 24'h131;
        #5 saddress = 16'h1D8;
        #5 swr = 1;    // początek operacji zapisu
        #5 swr = 0;    // koniec operacji zapisu

        #5 sdata_in = 24'h121;
        #5 saddress = 16'h1E0;
        #5 swr = 1;
        #5 swr = 0;

        #5 saddress = 16'h1E8; // oczekiwany wynik: 15851  (W)
        #5 srd = 1;
        #5 srd = 0;

        #5 saddress = 16'h1F0; // oczekiwany wynik: 7   (L)
        #5 srd = 1;
        #5 srd = 0;

        #5 saddress = 16'h1F8; // oczekiwany wynik: 0   (B)
        #5 srd = 1;
        #5 srd = 0;

        // Sprawdzenie: overflow


        #5 sdata_in = 24'hFFFFFF;
        #5 saddress = 16'h1D8;
        #5 swr = 1;    // początek operacji zapisu
        #5 swr = 0;    // koniec operacji zapisu

        #5 sdata_in = 24'hFFFFFF;
        #5 saddress = 16'h1E0;
        #5 swr = 1;
        #5 swr = 0;

        #5 saddress = 16'h1E8; // (W)
        #5 srd = 1;
        #5 srd = 0;

        #5 saddress = 16'h1F0; // (L)
        #5 srd = 1;
        #5 srd = 0;

        #5 saddress = 16'h1F8; // oczekiwany wynik: -1   (B)
        #5 srd = 1;
        #5 srd = 0;

        # 2000 $finish;
    end

    gpioemu e1(n_reset, saddress, srd, swr, sdata_in, /*sdata_out*/, gpio_in, gpio_latch, /*gpio_out*/, clk, gpio_in_s_insp);


endmodule