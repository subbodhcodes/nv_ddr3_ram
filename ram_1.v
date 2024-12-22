module nv_ddre(
    input clk, rst,         
    input [17:0] user_data,  
    input enable, rd_en, wr_en, power_enable,
    input [1:0]clk_mode, // 2'b00: posedge-only, 2'b01: negedge-only, 2'b10: DDR mode (both edges)
    output reg [7:0] user_out,
    output reg refresh_int
);

reg [1:0] state;
parameter IDLE = 2'b00, READ = 2'b01, WRITE = 2'b10, REFRESH = 2'b11;


reg [7:0] memory[15:0][15:0];


wire [3:0] row_add = user_data[11:8];
wire [3:0] col_add = user_data[15:12];
wire rd = user_data[17];
wire wr = user_data[16];

reg [7:0] memory_temp [15:0];
//reg refresh_int, refresh_out;

reg [3:0] read_counter;
reg [3:0] write_counter;

integer i, j;


always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                memory[i][j] = 8'b0;
            end
        end
        state <= IDLE;
        user_out <= 8'b0;
        read_counter <= 4'b0;
        write_counter <= 4'b0;
    end
    else if (enable && (clk_mode == 2'b00 || clk_mode == 2'b10 ))begin
        process_state();
    end
end


always@(negedge clk) begin
    if(enable && (clk_mode == 2'b01) || clk_mode == 2'b10) begin
        process_state();
    end
end


    task process_state; begin
        if (~power_enable) begin
            state <= REFRESH;
        end
        else begin
            case (state)
                IDLE: begin
                    user_out <= 8'b0;
                    if (rd_en)
                        state <= READ;
                    else if (wr_en)
                        state <= WRITE;
                end
                
                READ: begin
                    if (rd && read_counter >= 0) begin
                        user_out <= memory[row_add][col_add];
                        read_counter <= read_counter + 1;
                    end
                    else if (read_counter <= 16) begin
                        read_counter <= 4'b0;
                        state <= IDLE; 
                        //state <= IDLE;
                    end
                end
                
                WRITE: begin
                    if (wr && write_counter >= 0) begin
                        memory[row_add][col_add] <= user_data[7:0];
                        write_counter <= write_counter + 1;
                    end
                    else if (write_counter <= 16) begin
                        write_counter <= 4'b0;
                        state <= IDLE; 
                        //state <= IDLE;
                    end
                end
                
                REFRESH: begin
                    for(j = 0; j<16; j = j + 1) begin
                        memory_temp[j] = memory[15][j];
                    end

                    for(j = 0; j<16; j = j + 1) begin
                        if(memory_temp[j] != 0 ) begin
                            refresh_int = 1;
                        end
                        else begin
                            refresh_int = 0;
                        end
                    end

                    for (i = 15; i >= 0; i = i - 1) begin
                        for (j = 0; j < 16; j = j + 1) begin
                            memory[i][j] = memory[i-1][j];
                        end
                    end

                        
                    for (i = 15; i >= 0; i = i - 1) begin
                        for (j = 0; j < 16; j = j + 1) begin
                            memory[i-1][j] = memory[i][j];
                        end
                    end

                    for(i = 0; i<16; i = i + 1) begin
                        memory[15][i] = memory_temp[i];
                    end
                    //state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end
        //else if (~power_enable) begin
            //state <= REFRESH;
        //end    
    endtask


endmodule





