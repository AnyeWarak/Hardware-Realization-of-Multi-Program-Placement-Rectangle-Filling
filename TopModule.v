`timescale 1ns / 100ps

//Do NOT Modify This Module
module P1_Reg_8_bit (DataIn, DataOut, rst, clk);

    input [7:0] DataIn;
    output [7:0] DataOut;
    input rst;
    input clk;
    reg [7:0] DataReg;
   
    always @(posedge clk)
  	if(rst)
            DataReg <= 8'b0;
        else
            DataReg <= DataIn;
    assign DataOut = DataReg;
endmodule

//Do NOT Modify This Module
module P1_Reg_5_bit (DataIn, DataOut, rst, clk);

    input [4:0] DataIn;
    output [4:0] DataOut;
    input rst;
    input clk;
    reg [4:0] DataReg;
    
    always @(posedge clk)
        if(rst)
            DataReg <= 5'b0;
        else
            DataReg <= DataIn;
    assign DataOut = DataReg;
endmodule

//Do NOT Modify This Module
module P1_Reg_4_bit (DataIn, DataOut, rst, clk);

    input [3:0] DataIn;
    output [3:0] DataOut;
    input rst;
    input clk;
    reg [3:0] DataReg;
    
    always @(posedge clk)
        if(rst)
            DataReg <= 4'b0;
        else
            DataReg <= DataIn;
    assign DataOut = DataReg;
endmodule

//Do NOT Modify This Module's I/O Definition
module M216A_TopModule(
    clk_i,
    width_i,
    height_i,
    index_x_o,
    index_y_o,
    strike_o,
    rst_i
);

input clk_i;
input [4:0] width_i;
input [4:0] height_i;
output [7:0] index_x_o;
output [7:0] index_y_o;
output [3:0] strike_o;
input rst_i;

wire clk_i;
wire [4:0] width_i;
wire [4:0] height_i;
wire rst_i;

//Add your code below 
//Make sure to Register the outputs using the Register modules given above

// clock division module
    wire            clk1;
    wire            clk2;
    wire            clk3;
    wire            clk4;
    
    // Input sampling stage
    wire [4 : 0]    height_input;
    wire [4 : 0]    width_input;

    // Find Row stage
    wire [3 : 0]    internal_str_id_1;
    wire [3 : 0]    internal_str_id_2;
    wire [3 : 0]    internal_str_id_3;

    // Read reg arr stage
    wire [7 : 0]    occ_width_1_reg;
    wire [7 : 0]    occ_width_2_reg;
    wire [7 : 0]    occ_width_3_reg;
    wire            write_en;
    wire            read_en;

    // Min occupied width Combinational Logics
    wire [1 : 0]    min_occupied_width_no_s4;
    wire [3 : 0]    min_occupied_strip_id_s4;   
    wire [7 : 0]    min_occupied_strip_width_s4;

    wire [7 : 0]    min_occupied_strip_width_s5;
    wire [3 : 0]    min_occupied_strip_id_s5; 
    wire [3 : 0]    min_occupied_strip_id;
    wire [7 : 0]    new_occupied_strip_width;
    wire [3 : 0]    strike_count;

    // Stage 5 Combinational Logics
    wire            strike_flag_s5;
    wire [7 : 0]    new_occupied_strip_width_s5;
    wire [4 : 0]    width_in_s5;

    // find the output (x, y) index
    wire [7 : 0]    x_index;
    wire [7 : 0]    y_index;

////////////////////////////////////////////////////////////////////////////////////////////////////
    // Clock division module
    clk_div clk_div_inst (
        .clk_in     (clk_i  ),
        .rst_in     (rst_i  ),
        .clk1_out   (clk1   ),
        .clk2_out   (clk2   ),
        .clk3_out   (clk3   ),
        .clk4_out   (clk4   )
    );

////////////////////////////////////////////////////////////////////////////////////////////////////
    // Input sampling stage
    
    P1_Reg_5_bit_async height_in_reg (
        .clk        (clk1           ),
        .rst        (rst_i          ), 
        .DataIn     (height_i       ), 
        .DataOut    (height_input   )
    );
    
    P1_Reg_5_bit_async width_in_reg (
        .clk        (clk1           ),
        .rst        (rst_i          ), 
        .DataIn     (width_i        ), 
        .DataOut    (width_input    )
    );
    
////////////////////////////////////////////////////////////////////////////////////////////////////
    // Find Row stage

    Find_Row find_row_stage (
        .height_in  (height_input       ), 
        .width_in   (width_input        ), 
        .str_id_1   (internal_str_id_1  ), 
        .str_id_2   (internal_str_id_2  ), 
        .str_id_3   (internal_str_id_3  )
    );

////////////////////////////////////////////////////////////////////////////////////////////////////
    // pipeline registers between find row and read reg arr

////////////////////////////////////////////////////////////////////////////////////////////////////
    // Read reg arr stage

    r_w_enable r_w_enable_inst (
        .clk        (clk_i                  ),
        .rst        (rst_i                  ),
        .write_en   (write_en               ),
        .read_en    (read_en                )
    );

    ram ram (
        .clk        (clk_i && (clk2 || clk3)),
        .rst        (rst_i                  ),
        .write_en   (write_en && (!strike_flag_s5)),
        .read_en    (read_en                ),
        .addr_write (min_occupied_strip_id  ),
        .data_in    (new_occupied_strip_width),
        .addr_read1 (internal_str_id_1      ),
        .addr_read2 (internal_str_id_2      ),
        .addr_read3 (internal_str_id_3      ),
        .data_out1  (occ_width_1_reg        ),
        .data_out2  (occ_width_2_reg        ),
        .data_out3  (occ_width_3_reg        )
    );

////////////////////////////////////////////////////////////////////////////////////////////////////
    // pipeline registers between read reg arr and min occupied width

////////////////////////////////////////////////////////////////////////////////////////////////////
    //Min occupied width Combinational Logics
 
    Min_Occupied_Width_No  u_Min_Occupied_Width_No (
        .occupied_width_1           (occ_width_1_reg            ),
        .occupied_width_2           (occ_width_2_reg            ),
        .occupied_width_3           (occ_width_3_reg            ),
        .min_occupied_width_no      (min_occupied_width_no_s4   ) 
    );

    Min_Occupied_Strip_Selector  u_Min_Occupied_Strip_Selector (
        .strip_id_1                 (internal_str_id_1          ),
        .strip_id_2                 (internal_str_id_2          ),
        .strip_id_3                 (internal_str_id_3          ),
        .occupied_width_1           (occ_width_1_reg            ),
        .occupied_width_2           (occ_width_2_reg            ),
        .occupied_width_3           (occ_width_3_reg            ),
        .min_occupied_width_no      (min_occupied_width_no_s4   ),
        .min_occupied_strip_id      (min_occupied_strip_id_s4   ),
        .min_occupied_strip_width   (min_occupied_strip_width_s4)
    );

////////////////////////////////////////////////////////////////////////////////////////////////////
    // pipeline registers between min occupied width and stage 5

    P1_Reg_4_bit_async  u_min_occupied_strip_id_s4 (
        .clk        (clk4                       ),
        .rst        (rst_i                      ),
        .DataIn     (min_occupied_strip_id_s4   ),
        .DataOut    (min_occupied_strip_id_s5   )
    );

    P1_Reg_8_bit_async  u_min_occupied_strip_width_s4 (
        .clk        (clk4                       ),
        .rst        (rst_i                      ),
        .DataIn     (min_occupied_strip_width_s4),
        .DataOut    (min_occupied_strip_width_s5)
    );

    P1_Reg_5_bit_async  u_width_in_s4 (
        .clk        (clk4                       ),
        .rst        (rst_i                      ),
        .DataIn     (width_input                ),
        .DataOut    (width_in_s5                )
    );

////////////////////////////////////////////////////////////////////////////////////////////////////
    // Stage 5 Combinational Logics

    Strike_Detector  u_Strike_Detector (
        .min_occupied_strip_width   (min_occupied_strip_width_s5),
        .width_in                   (width_in_s5                ),
        .strike_flag                (strike_flag_s5             ),
        .new_occupied_strip_width   (new_occupied_strip_width_s5)
    );
    
    Strike_Counter  u_Strike_Counter (
        .clk            (clk1               ),
        .rst            (rst_i              ),
        .strike_flag    (strike_flag_s5     ),
        .strike_count   (strike_count       )  
    );

////////////////////////////////////////////////////////////////////////////////////////////////////
    // pipeline registers between stage 5 and write array
    
    P1_Reg_4_bit_async  u_min_occupied_strip_id_s5 (
        .clk        (clk1                       ),
        .rst        (rst_i                      ),            
        .DataIn     (min_occupied_strip_id_s5   ),
        .DataOut    (min_occupied_strip_id      )
    );

    P1_Reg_8_bit_async  u_new_occupied_strip_width_s5 (
        .clk        (clk1                       ),
        .rst        (rst_i                      ),
        .DataIn     (new_occupied_strip_width_s5),
        .DataOut    (new_occupied_strip_width   )
    );

////////////////////////////////////////////////////////////////////////////////////////////////////
    // write to register array

////////////////////////////////////////////////////////////////////////////////////////////////////
    // pipeline registers between write and index

////////////////////////////////////////////////////////////////////////////////////////////////////
    // find the output (x, y) index

    find_index find_index_inst (
        .strip_ID_in            (min_occupied_strip_id_s5   ),
        .occupied_width_in      (min_occupied_strip_width_s5),
        .strike_flag_in         (strike_flag_s5             ),
        .x_out                  (x_index                    ),
        .y_out                  (y_index                    )
    );

////////////////////////////////////////////////////////////////////////////////////////////////////
    // pipeline registers between index and output

////////////////////////////////////////////////////////////////////////////////////////////////////
    // output registers for x and y

    P1_Reg_4_bit P1_Reg_4_bit_inst4 (
        .clk        (clk4                       ),
        .rst        (rst_i                      ), 
        .DataIn     (strike_count               ),
        .DataOut    (strike_o                   )
    );

    P1_Reg_8_bit P1_Reg_8_bit_inst4 (
        .clk        (clk4                       ),
        .rst        (rst_i                      ), 
        .DataIn     (x_index                    ),
        .DataOut    (index_x_o                  )
    );

    P1_Reg_8_bit P1_Reg_8_bit_inst5 (
        .clk        (clk4                       ),
        .rst        (rst_i                      ), 
        .DataIn     (y_index                    ),
        .DataOut    (index_y_o                  )
    );

endmodule

module clk_div(
    input       clk_in,
    input       rst_in,

    output      clk1_out,
    output      clk2_out,
    output      clk3_out,
    output      clk4_out
);
    
    parameter   CLK1 = 0;
    parameter   CLK2 = 1;
    parameter   CLK3 = 2;
    parameter   CLK4 = 3;
    
    reg [1 : 0] current_state;
    reg [1 : 0] next_state;
    reg         clk1;
    reg         clk2;
    reg         clk3;
    reg         clk4;

    always @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            current_state = 2'b00;
            next_state    = 2'b00;
            clk1          = 1'b0;
            clk2          = 1'b0;
            clk3          = 1'b0;
            clk4          = 1'b0;
        end
        else begin
            case (current_state)
                CLK1: begin
                    next_state  = CLK2;
                    clk1        = 1'b1;
                    clk2        = 1'b0;
                    clk3        = 1'b0;
                    clk4        = 1'b0;
                end
                CLK2: begin
                    next_state  = CLK3;
                    clk1        = 1'b0;
                    clk2        = 1'b1;
                    clk3        = 1'b0;
                    clk4        = 1'b0;
                end
                CLK3: begin
                    next_state  = CLK4;
                    clk1        = 1'b0;
                    clk2        = 1'b0;
                    clk3        = 1'b1;
                    clk4        = 1'b0;
                end
                CLK4: begin
                    next_state  = CLK1;
                    clk1        = 1'b0;
                    clk2        = 1'b0;
                    clk3        = 1'b0;
                    clk4        = 1'b1;
                end
                default: begin
                    next_state  = CLK4;
                    clk1        = 1'b0;
                    clk2        = 1'b0;
                    clk3        = 1'b0;
                    clk4        = 1'b0;
                end
            endcase
            current_state = next_state;
        end
    end

    assign clk1_out = clk2;
    assign clk2_out = clk3;
    assign clk3_out = clk4;
    assign clk4_out = clk1;

endmodule

module Find_Row(height_in, width_in, str_id_1, str_id_2, str_id_3);
    input [4:0] height_in, width_in;
    output reg [3:0] str_id_1, str_id_2, str_id_3;

    always @(*)
    begin
        case (height_in)
            5'd4: {str_id_1, str_id_2, str_id_3}    = {4'd10, 4'd8,  4'd0};
            5'd5: {str_id_1, str_id_2, str_id_3}    = {4'd8,  4'd6,  4'd0};
            5'd6: {str_id_1, str_id_2, str_id_3}    = {4'd6,  4'd4,  4'd0};
            5'd7: {str_id_1, str_id_2, str_id_3}    = {4'd4,  4'd1,  4'd2};
            5'd8: {str_id_1, str_id_2, str_id_3}    = {4'd1,  4'd2,  4'd3};
            5'd9: {str_id_1, str_id_2, str_id_3}    = {4'd3,  4'd5,  4'd0};
            5'd10:{str_id_1, str_id_2, str_id_3}    = {4'd5,  4'd7,  4'd0};
            5'd11:{str_id_1, str_id_2, str_id_3}    = {4'd7,  4'd9,  4'd0};
            5'd12:{str_id_1, str_id_2, str_id_3}    = {4'd9,  4'd0,  4'd0};
            5'd13, 5'd14, 5'd15, 5'd16:  
                  {str_id_1, str_id_2, str_id_3}    = {4'd13, 4'd12, 4'd11};
            default: 
                  {str_id_1, str_id_2, str_id_3}    = {4'd0,  4'd0,  4'd0};
        endcase
    end
endmodule

module r_w_enable (
    input       clk,
    input       rst,

    output wire write_en,
    output wire read_en
);
    reg [1 : 0] counter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 2'b00;
        end
        else begin
            counter <= counter + 1;
        end
    end

    assign write_en = (counter == 2'b10);
    assign read_en  = (counter == 2'b11);

endmodule

module ram #(
    parameter ADDR_WIDTH = 4,  // strip number = 13, need 4 bits to store
    parameter DATA_WIDTH = 8   
)(
    input                               clk,     
    input                               rst, 
    input                               write_en,
    input                               read_en,     
    input  [ADDR_WIDTH - 1 : 0]         addr_write, 
    input  [DATA_WIDTH - 1 : 0]         data_in,    

    input  [ADDR_WIDTH - 1 : 0]         addr_read1,   
    input  [ADDR_WIDTH - 1 : 0]         addr_read2, 
    input  [ADDR_WIDTH - 1 : 0]         addr_read3, 

    output reg [DATA_WIDTH - 1 : 0]     data_out1,
    output reg [DATA_WIDTH - 1 : 0]     data_out2, 
    output reg [DATA_WIDTH - 1 : 0]     data_out3  
);

    reg [DATA_WIDTH - 1 : 0]    ram [0 : 13];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ram[0]  <= 8'd128;
            ram[1]  <= 8'b0;
            ram[2]  <= 8'b0;
            ram[3]  <= 8'b0;
            ram[4]  <= 8'b0;
            ram[5]  <= 8'b0;
            ram[6]  <= 8'b0;
            ram[7]  <= 8'b0;
            ram[8]  <= 8'b0;
            ram[9]  <= 8'b0;
            ram[10] <= 8'b0;
            ram[11] <= 8'b0;
            ram[12] <= 8'b0;
            ram[13] <= 8'b0;
            data_out1 <= 8'b0;
            data_out2 <= 8'b0;
            data_out3 <= 8'b0;
        end
        else begin
            if (write_en && addr_write) begin
                ram[addr_write] <= data_in;
            end
            else if (read_en) begin
                data_out1 <= ram[addr_read1];
                data_out2 <= ram[addr_read2];
                data_out3 <= ram[addr_read3];
            end
        end
    end

endmodule

module Min_Occupied_Width_No (
    occupied_width_1,
    occupied_width_2,
    occupied_width_3,
    min_occupied_width_no
);

    //if certain occupied width is not used, set it as 7'd128
    input [7:0] occupied_width_1;
    input [7:0] occupied_width_2;
    input [7:0] occupied_width_3;

    //generate the number of strip that has min_occupied_width
    output [1:0] min_occupied_width_no; 

    reg [1:0] occupied_width_no;

    always @(*) begin
        if (occupied_width_1 > occupied_width_2) 
            occupied_width_no = (occupied_width_2 > occupied_width_3)? 2'd3 : 2'd2;
        else 
            occupied_width_no = (occupied_width_1 > occupied_width_3)? 2'd3 : 2'd1;
    end

    assign min_occupied_width_no = occupied_width_no;

endmodule

module Min_Occupied_Strip_Selector(
    strip_id_1,
    strip_id_2,
    strip_id_3,
    occupied_width_1,
    occupied_width_2,
    occupied_width_3,
    min_occupied_width_no,

    min_occupied_strip_id,
    min_occupied_strip_width
);

    input [3:0] strip_id_1;
    input [3:0] strip_id_2;
    input [3:0] strip_id_3;
    input [7:0] occupied_width_1;
    input [7:0] occupied_width_2;
    input [7:0] occupied_width_3;
    input [1:0] min_occupied_width_no;

    output reg [3:0] min_occupied_strip_id;
    output reg [7:0] min_occupied_strip_width;

    always @* begin
        case(min_occupied_width_no)
            2'd1: begin
                min_occupied_strip_id <= strip_id_1;
                min_occupied_strip_width <= occupied_width_1;
            end
            2'd2: begin
                min_occupied_strip_id <= strip_id_2;
                min_occupied_strip_width <= occupied_width_2;
            end
            2'd3: begin
                min_occupied_strip_id <= strip_id_3;
                min_occupied_strip_width <= occupied_width_3;
            end
            default:begin
                min_occupied_strip_id <= 0;
                min_occupied_strip_width <= 0;
            end
        endcase
    end

endmodule

module Strike_Detector(
    min_occupied_strip_width,
    width_in,

    strike_flag,
    new_occupied_strip_width
);

    input [7:0] min_occupied_strip_width;
    input [4:0] width_in;

    output reg strike_flag;
    output reg [7:0] new_occupied_strip_width;

    always @(*) begin
        new_occupied_strip_width = min_occupied_strip_width + {3'b000 , width_in};
        if (new_occupied_strip_width > 8'd128) 
            strike_flag = 1;
        else
            strike_flag = 0;
    end

endmodule

module Strike_Counter(
    strike_flag,
    clk,
    rst,

    strike_count
);
    
    input strike_flag;
    input clk;
    input rst; //high active

    output reg [3:0] strike_count;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin 
            strike_count <= 0;
        end
        else if(strike_flag) begin
            strike_count <= strike_count + 1;
        end
    end

endmodule

module find_index (
    // input signals
    input [3 : 0]       strip_ID_in,
    input [7 : 0]       occupied_width_in,
    //input [3 : 0]       strike_in,
    input               strike_flag_in,

    // output signals
    output reg [7 : 0]  x_out,
    output reg [7 : 0]  y_out
    //output reg [3 : 0]  strike_out
);

    always @(*) begin
        if(strike_flag_in) begin
            x_out <= 128;
            y_out <= 128;
        end
        else begin
            // calculate y
            case(strip_ID_in)
                'd1:    y_out <= 0; 
                'd2:    y_out <= 8;
                'd3:    y_out <= 16;
                'd4:    y_out <= 25;
                'd5:    y_out <= 32;
                'd6:    y_out <= 42;
                'd7:    y_out <= 48;
                'd8:    y_out <= 59;
                'd9:    y_out <= 64;
                'd10:   y_out <= 76;
                'd11:   y_out <= 80;
                'd12:   y_out <= 96;
                'd13:   y_out <= 112;
                default: y_out <= 0;
            endcase
            // calculate x
            if (strip_ID_in == 0)
                x_out <= 0;
            else
                x_out <= occupied_width_in; // (from 0)
        end
        //strike_out <= strike_in;
    end

endmodule

module P1_Reg_4_bit_async (DataIn, DataOut, rst, clk);

    input [3:0] DataIn;
    output [3:0] DataOut;
    input rst;
    input clk;
    reg [3:0] DataReg;
    
    always @(posedge clk or posedge rst)
        if(rst)
            DataReg <= 4'b0;
        else
            DataReg <= DataIn;
    assign DataOut = DataReg;
endmodule

module P1_Reg_5_bit_async (DataIn, DataOut, rst, clk);

    input [4:0] DataIn;
    output [4:0] DataOut;
    input rst;
    input clk;
    reg [4:0] DataReg;
    
    always @(posedge clk or posedge rst)
        if(rst)
            DataReg <= 5'b0;
        else
            DataReg <= DataIn;
    assign DataOut = DataReg;
endmodule

module P1_Reg_8_bit_async (DataIn, DataOut, rst, clk);

    input [7:0] DataIn;
    output [7:0] DataOut;
    input rst;
    input clk;
    reg [7:0] DataReg;
   
    always @(posedge clk or posedge rst)
  	    if(rst)
            DataReg <= 8'b0;
        else
            DataReg <= DataIn;
    assign DataOut = DataReg;
endmodule