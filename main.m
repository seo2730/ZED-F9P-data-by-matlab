close all
clear
clc
delete(instrfindall); %Solved unavailable port error
MyPort = serial('COM12','baudrate',9600,'databits',8,'parity','none','stopbits',1,'readasyncmode','continuous');
fopen(MyPort);
disp(MyPort)
disp('Start reading')
data_count = 0;
ubx_data = zeros(100,1);
ubx_data = string(ubx_data);
DATA_LENGTH_CHECK = zeros(2,1);
packet_check_length = 2;
data_count = 1;
%----------------------Get some samples --------------------------------

READY1 = 0xB5;
READY2 = 0x62;
READY3 = 0x02;
PSEUDORANGE = 0x15;
EPHEMERIS = 0x13;
ID = 0x00;

STATE = 1;
STATE_READY1 = 1;
STATE_READY2 = 2;
STATE_READY3 = 3;
STATE_READY4 = 4;

STATE_LENGTH1 = 5;
STATE_LENGTH2 = 6;
STATE_REAL_DATA_PSEUDO = 7;
STATE_REAL_READY_PSEUDO = 8;

STATE_REAL_DATA_EPHEMERIS = 9;
STATE_REAL_READY_EPHEMERIS = 10;

GPS = 0;
GAL = 2;
BDS = 3;
GLO = 6;

parsing_count = 1;

satellite = [];

for i = 1:100000
    Data = fread(MyPort,1);
    %     x(i) = uint64(Data);
    x = uint8(Data);
    instant = dec2hex(Data);
    %fprintf("%02x,", x);
    %     if x(i) == 181
    switch STATE
        case STATE_READY1
            if x == READY1
                STATE = STATE_READY2;
            else
                STATE = STATE_READY1;
            end
        case STATE_READY2
            if x == READY2
                STATE = STATE_READY3;
            else
                STATE = STATE_READY1;
            end
        case STATE_READY3
            if x == READY3
                STATE = STATE_READY4;
            else
                STATE = STATE_READY1;
            end
        case STATE_READY4
            if x == PSEUDORANGE 
                STATE = STATE_LENGTH1;
                ID = PSEUDORANGE;
            elseif x == EPHEMERIS
                STATE = STATE_LENGTH1;
                ID = EPHEMERIS;
            else
                STATE = STATE_READY1;
            end
        case STATE_LENGTH1
            %x에 들어온 값을 쌓아야함 
            DATA_LENGTH_CHECK(1,1) = x;
            STATE = STATE_LENGTH2;
            
        case STATE_LENGTH2
            DATA_LENGTH_CHECK(2,1) = x;
            cal_hex1 = dec2hex(DATA_LENGTH_CHECK(1,1));
            cal_hex2 = dec2hex(DATA_LENGTH_CHECK(2,1));
            cal_hex = append(cal_hex2, cal_hex1);
            data_length = hex2dec(cal_hex);
            data_packet = zeros(data_length+packet_check_length,1);
            data_packet = string(data_packet);
            
            if ID == PSEUDORANGE 
                sat_num = (data_length-16)/32;          % 연결되어 있는 인공위성 수
                sat_data = zeros(sat_num, 32);
                sat_data = string(sat_data);
                STATE = STATE_REAL_DATA_PSEUDO;
            elseif ID == EPHEMERIS
                STATE = STATE_REAL_DATA_EPHEMERIS;
            end
            
        case STATE_REAL_DATA_PSEUDO
            data_packet(data_count,1) = dec2hex(x);
            data_count = data_count + 1;
            
            if data_count == data_length + 2
                STATE = STATE_REAL_READY_PSEUDO;
            end
        case STATE_REAL_READY_PSEUDO
            for j = 1:sat_num
                sat_data(j,:) = data_packet((32*(j-1)+1)+16 : 32*(j)+16 , 1)';
            end
            pseudo_range_raw = sat_data(1:sat_num, 1:8);
            carrier_phase_raw = sat_data(1:sat_num, 9:16);
            gnssID = sat_data(1:sat_num,21);
            svID = hex2dec(sat_data(1:sat_num,22));
            data_count = 1;
            clearvars data_packet
            STATE = STATE_READY1;
            %fprintf("\n");
            pseudo_range = GetPseudoRange(pseudo_range_raw);
            carrier_phase = GetCarrierPhase(carrier_phase_raw);
            satellite = [gnssID svID pseudo_range carrier_phase];
            
        case STATE_REAL_DATA_EPHEMERIS
            data_packet(data_count,1) = dec2hex(x);%data_packet(data_count,1:8) = de2bi(x,8,'left-msb');
            if data_count == 1
               if x == 0
                   fprintf("GPS ");
                   sat = GPS;
                   GPS_ephemeris_raw = zeros((data_length-8),1);
                   GPS_ephemeris_raw = string(GPS_ephemeris_raw);
               elseif x == 2
                   %fprintf("GAL ")
                   sat = GAL;
                   GAL_ephemeris_raw = zeros((data_length-8),1);
                   GAL_ephemeris_raw = string(GAL_ephemeris_raw);
               elseif x == 3 
                   %fprintf("BDS ")
                   sat = BDS;
                   BDS_ephemeris_raw = zeros((data_length-8),1);
                   BDS_ephemeris_raw = string(BDS_ephemeris_raw);
               elseif x == 6
                   fprintf("GLO ")
                   sat = GLO;
                   GLO_ephemeris_raw = zeros((data_length-8),1);
                   GLO_ephemeris_raw = string(GLO_ephemeris_raw);
               end
               
            elseif data_count == 2
                if sat == GPS
                    fprintf("%d\n",x);
                    satID = x;
                elseif sat == GAL
                    %fprintf("%d : ",x);
                    satID = x;
                elseif sat == BDS
                    %fprintf("%d : ",x);
                    satID = x;
                elseif sat == GLO
                    fprintf("%d\n",x);
                    satID = x;
                end
                
                if ~isempty(satellite)
                    for j = 1:sat_num
                        if satellite(j,1) == string(sat)
                            if satellite(j,2) == string(satID)
                                cur_sat = j;
                            end
                        end
                    end
                end
                 
            elseif data_count >= 9 && data_count<=data_length
                if sat == GPS
                    GPS_ephemeris_raw(parsing_count,1) = data_packet(data_count,1);
                    parsing_count = parsing_count + 1;
                elseif sat == GAL
                    GAL_ephemeris_raw(parsing_count,1) = data_packet(data_count,1);
                    parsing_count = parsing_count + 1;
                elseif sat == BDS
                    BDS_ephemeris_raw(parsing_count,1) = data_packet(data_count,1);
                    parsing_count = parsing_count + 1;
                elseif sat == GLO
                    GLO_ephemeris_raw(parsing_count,1) = data_packet(data_count,1);
                    parsing_count = parsing_count + 1;
                end
            
            elseif data_count == data_length + 2
                STATE = STATE_REAL_READY_EPHEMERIS;                
            end
            data_count = data_count + 1;
            
        case STATE_REAL_READY_EPHEMERIS
            if sat == GPS
                gps_data = string(zeros((data_length-8)/4,4));
                for j = 1:(data_length-8)/4
                    gps_data(j,:) = GPS_ephemeris_raw(4*(j)-3:4*(j),1)';
                end
                
            elseif sat == GAL
                gal_data = string(zeros((data_length-8)/4,4));
                for j = 1:(data_length-8)/4
                    gal_data(j,:) = GAL_ephemeris_raw(4*(j)-3:4*(j),1)';
                end
            elseif sat == BDS
                bds_data = string(zeros((data_length-8)/4,4));
                for j = 1:(data_length-8)/4
                    bds_data(j,:) = BDS_ephemeris_raw(4*(j)-3:4*(j),1)';
                end 
            elseif sat == GLO
                glo_data = string(zeros((data_length-8)/4,4));
                for j = 1:(data_length-8)/4
                    glo_data(j,:) = GLO_ephemeris_raw(4*(j)-3:4*(j),1)';
                end                        
            end
            if sat == GPS
                GPS_parameter = GPS_ephemeris(gps_data);
                subframe_gps = GPS_parameter.FrameNumber();
                
                if subframe_gps == 1
                   [gps_WN,gps_toc,gps_af1,gps_af2,gps_af3] = GPS_parameter.subframe1();
                   if ~isempty(satellite)
                        satellite(cur_sat,5:9) = [gps_WN,gps_toc,gps_af1,gps_af2,gps_af3];
                   end
                elseif subframe_gps == 2
                   [gps_Crs,gps_del_n,gps_M0,gps_Cuc,gps_e,gps_Cus,gps_root_A,gps_toe] = GPS_parameter.subframe2();
                   if ~isempty(satellite)
                        satellite(cur_sat,10:17) = [gps_Crs,gps_del_n,gps_M0,gps_Cuc,gps_e,gps_Cus,gps_root_A,gps_toe];
                   end
                elseif subframe_gps == 3
                   [gps_Cic,gps_omega0,gps_Cis,gps_i0,gps_Crc,gps_w,gps_dot_omega,gps_dot_i] = GPS_parameter.subframe3();
                   if ~isempty(satellite)
                        satellite(cur_sat,18:25) = [gps_Cic,gps_omega0,gps_Cis,gps_i0,gps_Crc,gps_w,gps_dot_omega,gps_dot_i];              
                   end
                end                
            elseif sat == GLO
                GLO_parameter = GLO_ephemeris(glo_data);
                [frame,string_num] = GLO_parameter.frame();
                
                if frame == 1 || frame == 2 || frame == 3 || frame == 4
                   if string_num == 1
                       [glo_P1,glo_tk,glo_vx,glo_ax,glo_x] = GLO_parameter.string1();
                       %satellite(cur_sat,3:7) = [glo_P1,glo_tk,glo_vx,glo_ax,glo_x];
                   elseif string_num == 2
                       [glo_Bn,glo_P2,glo_tb,glo_vy,glo_ay,glo_y] = GLO_parameter.string2();
                       %satellite(cur_sat,8:13) = [glo_Bn,glo_P2,glo_tb,glo_vy,glo_ay,glo_y];
                   elseif string_num == 3
                       [glo_P3,glo_rn,glo_P,glo_ln,glo_vz,glo_az,glo_z] = GLO_parameter.string3();                       
                   elseif string_num == 4
                       [glo_taun,glo_del_taun,glo_En,glo_P4,glo_FT,glo_NT,glo_n,glo_M] = GLO_parameter.string4();                
                   elseif string_num == 5
                       [glo_NA,glo_tau_c,glo_N4,glo_tau_GPS,glo_ln] = GLO_parameter.string5();
                   elseif string_num == 6 || string_num == 8 || string_num == 10 || string_num == 12 || string_num == 14
                       [glo_Cn,glo_Man,glo_nA,glo_tau_An,glo_lamda_An,glo_del_i_An,glo_e_An] = GLO_parameter.string_even();
                   elseif string_num == 7 || string_num == 9 || string_num == 11 || string_num == 13 || string_num == 15
                       [glo_w_An,glo_tau_Alam,glo_del_T_An,glo_del_dotT_An,glo_del_H_An,glo_ln] = GLO_parameter.string_odd();
                   end
                   
                elseif frame == 5
                   if string_num == 1
                       [glo_P1,glo_tk,glo_vx,glo_ax,glo_x] = GLO_parameter.string1();                
                   elseif string_num == 2
                       [glo_Bn,glo_P2,glo_tb,glo_vy,glo_ay,glo_y] = GLO_parameter.string2();
                   elseif string_num == 3
                       [glo_P3,glo_rn,glo_P,glo_ln,glo_vz,glo_az,glo_z] = GLO_parameter.string3();                       
                   elseif string_num == 4
                       [glo_taun,glo_del_taun,glo_En,glo_P4,glo_FT,glo_NT,glo_n,glo_M] = GLO_parameter.string4();                
                   elseif string_num == 5
                       [glo_NA,glo_tau_e,glo_N4,glo_tau_GPS,glo_ln] = GLO_parameter.string5();
                   elseif string_num == 6 || string_num == 8 || string_num == 10 || string_num == 12 
                       [glo_Cn,glo_Man,glo_nA,glo_tau_An,glo_lamda_An,glo_del_i_An,glo_e_An] = GLO_parameter.string_even();
                   elseif string_num == 7 || string_num == 9 || string_num == 11 || string_num == 13 
                       [glo_w_An,glo_tau_Alam,glo_del_T_An,glo_del_dotT_An,glo_del_H_An,glo_ln] = GLO_parameter.string_odd();
                   elseif string_num == 14
                       [glo_B1,glo_B2,glo_KP] = GLO_parameter.string14_5();
                   end                    
                end
            end
            
            parsing_count = 1;
            data_count = 1;
%             clearvars data_packet
            STATE = STATE_READY1; 
        otherwise
    end
    
    
end

