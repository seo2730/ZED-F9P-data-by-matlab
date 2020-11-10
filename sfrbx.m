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
check = 1;
%----------------------Get some samples --------------------------------

READY1 = 0xB5;
READY2 = 0x62;
READY3 = 0x02;
READY4 = 0x13;

STATE = 1;
STATE_READY1 = 1;
STATE_READY2 = 2;
STATE_READY3 = 3;
STATE_READY4 = 4;

STATE_LENGTH1 = 5;
STATE_LENGTH2 = 6;
STATE_REAL_DATA = 7;
STATE_REAL_READY = 8;

GPS = 0;
GAL = 2;
BDS = 3;
GLO = 6;

parsing_count = 1;

for i = 1:10000
    Data = fread(MyPort,1);
    x(i) = uint64(Data);
    x = uint8(Data);
    instant = dec2hex(Data);
%     fprintf("%02x,", x);
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
            if x == READY4
                STATE = STATE_LENGTH1;
            else
                STATE = STATE_READY1;
            end
        case STATE_LENGTH1
            %x에 들어온 값을 쌓아야함 
            DATA_LENGTH_CHECK(1,1) = x;                     % 데이터 길이 첫번째 프로토콜(실제는 두번째 값)
            STATE = STATE_LENGTH2;
            
        case STATE_LENGTH2
            DATA_LENGTH_CHECK(2,1) = x;                     % 데이터 길이 두번째 프로토콜(실제는 첫번째 값)
            cal_hex1 = dec2hex(DATA_LENGTH_CHECK(1,1));
            cal_hex2 = dec2hex(DATA_LENGTH_CHECK(2,1));
            cal_hex = append(cal_hex2, cal_hex1);           % 데이터 길이(16진수) 
            data_length = hex2dec(cal_hex);                 % 데이터 길이(10진수)
            check_length(check,:) = data_length;
            data_packet = zeros(data_length+packet_check_length,1);
            ephemeris_data= zeros(1,data_length);
            data_packet = string(data_packet);
            STATE = STATE_REAL_DATA;
            check = check +1;
        case STATE_REAL_DATA
            data_packet(data_count,1) = dec2hex(x);%data_packet(data_count,1:8) = de2bi(x,8,'left-msb');
            if data_count == 1
               if x == 0
                   fprintf("GPS ");
                   sat = GPS;
               elseif x == 2
                   fprintf("GAL ")
                   sat = GAL;
               elseif x == 3 
                   fprintf("BDS ")
                   sat = BDS;
               elseif x == 6
                   fprintf("GLO ")
                   sat = GLO;
               end
               
            elseif data_count == 2
                if sat == GPS
                    fprintf("%d : ",x);
                elseif sat == GAL
                    fprintf("%d : ",x);
                elseif sat == BDS
                    fprintf("%d : ",x);
                elseif sat == GLO
                    fprintf("%d : ",x);
                end
                 
            elseif data_count >= 9 && data_count<=data_length
                if sat == GPS
                    %ephemeris_data(1,parsing_count) = data_packet(data_count,1);
                    fprintf("%02x,", x);
                elseif sat == GAL
                    %ephemeris_data(1,parsing_count) = data_packet(data_count,1);
                    fprintf("%02x,", x);
                elseif sat == BDS
                    %ephemeris_data(1,parsing_count) = data_packet(data_count,1);
                    fprintf("%02x,", x);
                elseif sat == GLO
                    %ephemeris_data(1,parsing_count) = data_packet(data_count,1);
                    fprintf("%02x,", x);
                end
                %parsing_count = parsing_count+1;
                 
            elseif data_count == data_length + 1
                %parsing_count = 1;
                %fprintf(ephemeris_data)
                fprintf("\n");
            elseif data_count == data_length + 2
                STATE = STATE_REAL_READY;                
            end
            data_count = data_count + 1;
            
        case STATE_REAL_READY
            data_count = 1;
%             clearvars data_packet
            STATE = STATE_READY1;
%             fprintf("\n");
        otherwise
            
    end
  
    
end

