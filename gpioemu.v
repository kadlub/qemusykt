/* verilator lint_off UNUSED */

/* verilator lint_off MULTIDRIVEN */

/* verilator lint_off UNDRIVEN */

/* verilator lint_off COMBDLY */

/* verilator lint_off WIDTH */

/* verilator lint_off BLKSEQ */

/* verilator lint_off BLKANDNBLK */

/* verilator lint_off CASEINCOMPLETE */

module gpioemu(n_reset,             // magistrala z CPU
    saddress[15:0], srd, swr, 
    sdata_in[31:0], sdata_out[31:0],
    gpio_in[31:0], gpio_latch,      //styk z GPIO - in
    gpio_out[31:0],                 // styk z GPIO = out
    clk,                            // sygnał opcjonalny - zegar 1kHz
    gpio_in_s_insp[31:0]);          // sygnały testowe


    
	input 				clk;
	input 				n_reset;

	input  [15:0] 		saddress;
	input 				srd;
	input 				swr;
	input  [31:0] 		sdata_in;
    output [31:0] 		sdata_out;
    reg    [31:0]       sdata_out_s;

	input  [31:0] 		gpio_in;
    reg    [31:0]       gpio_in_s;
	input				gpio_latch;
    output [31:0]       gpio_in_s_insp;
	
	output [31:0] 		gpio_out;
    reg    [31:0]       gpio_out_s;
    


    reg  [23:0]       A1;  // pierwsza liczba podawana jest przez ten rejestr (24 bity)
    reg  [23:0]       A2;  // druga liczba podawana jest przez ten rejestr (24 bity)
    reg  [31:0]       W;   // wynik mnozenia (32 bity)
    reg  [31:0]       L;   // liczba jedynek w wyniku
    reg  [31:0]       B;   // stan zleconej operacji

	reg	 [47:0]		  temp;

	integer i = 0;
	integer j = 0;




    always @(negedge n_reset)
	    begin
		    sdata_out_s <= 0;
		    gpio_out_s <= 0;
		    W <= 0;
		    L <= 0;
		    B <= 0; 
		    i <= 0;
		    j <= 0;
		    temp <= 0;
	    end



    always @(posedge gpio_latch)
	    begin
		    gpio_in_s <= gpio_in;
	    end



    always @(posedge swr) 
        begin
            if (B != 1) begin
                case(saddress)
                    16'h1D8: begin  // adres pierwszego argumentu
                        A1 <= sdata_in;
                        W <= 0;
                        L <= 0;
                        B <= 0;
                    end
                    16'h1E0: begin  // adres drugiego argumentu
                        A2 <= sdata_in;
                        W <= 0;
                        L <= 0;
                        B <= 1;
                    end
                endcase
            end
        end



    always @(posedge srd)
		begin
            case(saddress)                     
                16'h1D8: sdata_out_s <= A1; //zmiana z 1D7 ze wzgledu na niepodzielnosc przez 4
                16'h1E0: sdata_out_s <= A2;
                16'h1E8: sdata_out_s <= W;
                16'h1F0: sdata_out_s <= L;
                16'h1F8: sdata_out_s <= B;
                default: sdata_out_s <= 0;
            endcase
		end



    always @(posedge clk) begin
        if (B == 1) begin
            temp <= 0;


            for (i = 0; i < 23; i = i + 1) begin  // operacja mnozenia
                if(A2[i] == 1)
                begin
                    temp = temp + (A1<<i);
                end
            end
            for (j = 0; j < 47; j = j + 1) begin // operacja zliczania jedynek
                L = L + (temp[j] == 1);
            end
            
            if (temp > 2**32 - 1) begin  // overflow
                B <= 2;
                i <= 0;
                j <= 0;
                A1 <= 0;
                A2 <= 0;
                W <= temp[47:16];
                gpio_out_s <= gpio_out_s + 1;
            end 
            else begin
                B <= 0; // zakonczenie operacji
                i <= 0;
                j <= 0;
                A1 <= 0;
                A2 <= 0;
                W <= temp;
                gpio_out_s <= gpio_out_s + 1;
            end
        end
    end


    assign gpio_out = gpio_out_s[15:0];
	assign sdata_out = sdata_out_s;
	assign gpio_in_s_insp = gpio_in_s;



endmodule