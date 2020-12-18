clear
clc
delete(instrfindall); %Solved unavailable port error
MyPort = serial('COM28','baudrate',9600,'databits',8,'parity','none','stopbits',1,'readasyncmode','continuous');
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

pseudo_list = [];
eph_list = [];
eph_count = 1;
cur_sat = 0;

sat = 100;
for i = 1:1000000
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
            else
                STATE = STATE_READY1;
            end
        case STATE_LENGTH1
             %x?óê ?ì§?ñ¥?ò® Í∞íÏùÑ ?åì?ïÑ?ïº?ï® 
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
            sat_num = (data_length-16)/32;          % ?ó∞Í≤∞Îêò?ñ¥ ?ûà?äî ?ù∏Í≥µÏúÑ?Ñ± ?àò
            sat_data = zeros(sat_num, 32);
            sat_data = string(sat_data);
            STATE = STATE_REAL_DATA_PSEUDO;

   
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
            pseudo_list = [gnssID svID pseudo_range carrier_phase]
        otherwise
    end
    
    
end


