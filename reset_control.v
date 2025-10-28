module reset_control (
    input wire clk,
    input wire reset_button_n, 
    output wire reset_n 
);

   reg [10:0] reset_count = 0; 
    
	assign reset_n = &reset_count;
	 
	always @(posedge clk) begin
		 if (~reset_button_n) begin 
			  reset_count <= 'b0;

		 end
		 else begin 
			  reset_count <= reset_count + !reset_n;
		 end
	end
    
endmodule
