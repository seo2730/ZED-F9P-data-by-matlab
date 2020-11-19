function [X,Y,Z,vx,vy,vz,x,y,z,te] = Glonass_GetEphemeris(ephemeris_raw_data)

    raw_data = fliplr(ephemeris_raw_data);
    protocol = char(zeros(4,32));

    for j = 1:4
        for i = 1:4
             protocol(j,(8*(i)-7):8*(i)) = dec2bin(hex2dec(raw_data(j,i)),8);
        end
    end
    frame = bin2dec(protocol(4,2:5));
    string = bin2dec(protocol(1,2:5));
    if frame == 1 || frame == 2 || frame == 3 || frame == 4
        if string == 1
            P1 = bin2dec(protocol(1,8:9));
            tk = bin2dec(protocol(1,10:21));
            vx = bin2dec(append(protocol(1,22:32),protocol(2,1:13)));
            ax = bin2dec(protocol(2,14:18));
            x  = bin2dec(append(protocol(2,19:32),protocol(3,1:13)));
        elseif string == 2
            Bn = bin2dec(protocol(1,6:8));
            P2 = bin2dec(protocol(1,9));
            tb = bin2dec(protocol(1,10:16));
            vy = bin2dec(append(protocol(1,22:32),protocol(2,1:13)));
            ay = bin2dec(protocol(2,14:18));
            y  = bin2dec(append(protocol(2,19:32),protocol(3,1:13)));
        elseif string == 3
            P3 = bin2dec(protocol(1,6));
            rn = bin2dec(protocol(1,7:17));
            P  = bin2dec(protocol(1,20));
            ln = bin2dec(protocol(1,21));
            vz = bin2dec(append(protocol(1,22:32),protocol(2,1:13)));
            az = bin2dec(protocol(2,14:18));
            z  = bin2dec(append(protocol(2,19:32),protocol(3,1:13)));
        elseif string == 4
            taun = bin2dec(protocol(1,6:27));
            del_taun = bin2dec(protocol(1,28:32));
            En = bin2dec(protocol(2,1:5));
            P4 = bin2dec(protocol(2,20));
            FT = bin2dec(protocol(2,21:24));
            NT = bin2dec(append(protocol(2,28:32),protocol(3,1:6)));
            n  = bin2dec(protocol(3,7:11));
            M = bin2dec(protocol(3,12:13));
        elseif string == 5
            NA = bin2dec(protocol(1,6:16));
            tau_e = bin2dec(append(protocol(1,17:32),protocol(2,1:16)));
            N4 = bin2dec(protocol(2,18:22));
            tau_GPS = bin2dec(append(protocol(2,23:32),protocol(3,1:12)));
            ln = bin2dec(protocol(3,13));
        elseif string == 6
            Cn = bin2dec(protocol(1,6));
            Man = bin2dec(protocol(1,7:8));
            nA  = bin2dec(protocol(1,9:13));
            tau_An = bin2dec(protocol(1,14:23));
            lamda_An = bin2dec(append(protocol(1,24:32),protocol(2,1:12)));
            del_i_An = bin2dec(protocol(2,13:30));
            e_An = bin2dec(append(protocol(2,31:32),protocol(3,1:13)));
        elseif string == 7
            w_An = bin2dec(protocol(1,6:21));
            tau_Alam = bin2dec(append(protocol(1,22:32),protocol(2,1:10)));
            del_T_An = bin2dec(protocol(2,11:32));
            del_dotT_An = bin2dec(protocol(3,1:7));
            del_H_An = bin2dec(protocol(3,8:12));
            ln = bin2dec(protocol(3,13));
        elseif string == 8
            Cn = bin2dec(protocol(1,6));
            Man = bin2dec(protocol(1,7:8));
            nA  = bin2dec(protocol(1,9:13));
            tau_An = bin2dec(protocol(1,14:23));
            lamda_An = bin2dec(append(protocol(1,24:32),protocol(2,1:12)));
            del_i_An = bin2dec(protocol(2,13:30));
            e_An = bin2dec(append(protocol(2,31:32),protocol(3,1:13)));
        elseif string == 9
            w_An = bin2dec(protocol(1,6:21));
            tau_Alam = bin2dec(append(protocol(1,22:32),protocol(2,1:10)));
            del_T_An = bin2dec(protocol(2,11:32));
            del_dotT_An = bin2dec(protocol(3,1:7));
            del_H_An = bin2dec(protocol(3,8:12));
            ln = bin2dec(protocol(3,13));           
        elseif string == 10
            Cn = bin2dec(protocol(1,6));
            Man = bin2dec(protocol(1,7:8));
            nA  = bin2dec(protocol(1,9:13));
            tau_An = bin2dec(protocol(1,14:23));
            lamda_An = bin2dec(append(protocol(1,24:32),protocol(2,1:12)));
            del_i_An = bin2dec(protocol(2,13:30));
            e_An = bin2dec(append(protocol(2,31:32),protocol(3,1:13)));
        elseif string == 11
            w_An = bin2dec(protocol(1,6:21));
            tau_Alam = bin2dec(append(protocol(1,22:32),protocol(2,1:10)));
            del_T_An = bin2dec(protocol(2,11:32));
            del_dotT_An = bin2dec(protocol(3,1:7));
            del_H_An = bin2dec(protocol(3,8:12));
            ln = bin2dec(protocol(3,13));
        elseif string == 12
            Cn = bin2dec(protocol(1,6));
            Man = bin2dec(protocol(1,7:8));
            nA  = bin2dec(protocol(1,9:13));
            tau_An = bin2dec(protocol(1,14:23));
            lamda_An = bin2dec(append(protocol(1,24:32),protocol(2,1:12)));
            del_i_An = bin2dec(protocol(2,13:30));
            e_An = bin2dec(append(protocol(2,31:32),protocol(3,1:13)));
        elseif string == 13
            w_An = bin2dec(protocol(1,6:21));
            tau_Alam = bin2dec(append(protocol(1,22:32),protocol(2,1:10)));
            del_T_An = bin2dec(protocol(2,11:32));
            del_dotT_An = bin2dec(protocol(3,1:7));
            del_H_An = bin2dec(protocol(3,8:12));
            ln = bin2dec(protocol(3,13));
        elseif string == 14
            Cn = bin2dec(protocol(1,6));
            Man = bin2dec(protocol(1,7:8));
            nA  = bin2dec(protocol(1,9:13));
            tau_An = bin2dec(protocol(1,14:23));
            lamda_An = bin2dec(append(protocol(1,24:32),protocol(2,1:12)));
            del_i_An = bin2dec(protocol(2,13:30));
            e_An = bin2dec(append(protocol(2,31:32),protocol(3,1:13)));
        elseif string == 15
            w_An = bin2dec(protocol(1,6:21));
            tau_Alam = bin2dec(append(protocol(1,22:32),protocol(2,1:10)));
            del_T_An = bin2dec(protocol(2,11:32));
            del_dotT_An = bin2dec(protocol(3,1:7));
            del_H_An = bin2dec(protocol(3,8:12));
            ln = bin2dec(protocol(3,13));
        end
        
    elseif frame == 5
        if string == 1
            P1 = bin2dec(protocol(1,8:9));
            tk = bin2dec(protocol(1,10:21));
            vx = bin2dec(append(protocol(1,22:32),protocol(2,1:13)));
            ax = bin2dec(protocol(2,14:18));
            x  = bin2dec(append(protocol(2,19:32),protocol(3,1:13)));
        elseif string == 2
            Bn = bin2dec(protocol(1,6:8));
            P2 = bin2dec(protocol(1,9));
            tb = bin2dec(protocol(1,10:16));
            vy = bin2dec(append(protocol(1,22:32),protocol(2,1:13)));
            ay = bin2dec(protocol(2,14:18));
            y  = bin2dec(append(protocol(2,19:32),protocol(3,1:13)));
        elseif string == 3
            P3 = bin2dec(protocol(1,6));
            rn = bin2dec(protocol(1,7:17));
            P  = bin2dec(protocol(1,20));
            ln = bin2dec(protocol(1,21));
            vz = bin2dec(append(protocol(1,22:32),protocol(2,1:13)));
            az = bin2dec(protocol(2,14:18));
            z  = bin2dec(append(protocol(2,19:32),protocol(3,1:13)));
        elseif string == 4
            taun = bin2dec(protocol(1,6:27));
            del_taun = bin2dec(protocol(1,28:32));
            En = bin2dec(protocol(2,1:5));
            P4 = bin2dec(protocol(2,20));
            FT = bin2dec(protocol(2,21:24));
            NT = bin2dec(append(protocol(2,28:32),protocol(3,1:6)));
            n  = bin2dec(protocol(3,7:11));
            M = bin2dec(protocol(3,12:13));
        elseif string == 5
            NA = bin2dec(protocol(1,6:16));
            tau_e = bin2dec(append(protocol(1,17:32),protocol(2,1:16)));
            N4 = bin2dec(protocol(2,18:22));
            tau_GPS = bin2dec(append(protocol(2,23:32),protocol(3,1:12)));
            ln = bin2dec(protocol(3,13));
        elseif string == 6
            Cn = bin2dec(protocol(1,6));
            Man = bin2dec(protocol(1,7:8));
            nA  = bin2dec(protocol(1,9:13));
            tau_An = bin2dec(protocol(1,14:23));
            lamda_An = bin2dec(append(protocol(1,24:32),protocol(2,1:12)));
            del_i_An = bin2dec(protocol(2,13:30));
            e_An = bin2dec(append(protocol(2,31:32),protocol(3,1:13)));
        elseif string == 7
            w_An = bin2dec(protocol(1,6:21));
            tau_Alam = bin2dec(append(protocol(1,22:32),protocol(2,1:10)));
            del_T_An = bin2dec(protocol(2,11:32));
            del_dotT_An = bin2dec(protocol(3,1:7));
            del_H_An = bin2dec(protocol(3,8:12));
            ln = bin2dec(protocol(3,13));
        elseif string == 8
            Cn = bin2dec(protocol(1,6));
            Man = bin2dec(protocol(1,7:8));
            nA  = bin2dec(protocol(1,9:13));
            tau_An = bin2dec(protocol(1,14:23));
            lamda_An = bin2dec(append(protocol(1,24:32),protocol(2,1:12)));
            del_i_An = bin2dec(protocol(2,13:30));
            e_An = bin2dec(append(protocol(2,31:32),protocol(3,1:13)));
        elseif string == 9
            w_An = bin2dec(protocol(1,6:21));
            tau_Alam = bin2dec(append(protocol(1,22:32),protocol(2,1:10)));
            del_T_An = bin2dec(protocol(2,11:32));
            del_dotT_An = bin2dec(protocol(3,1:7));
            del_H_An = bin2dec(protocol(3,8:12));
            ln = bin2dec(protocol(3,13));            
        elseif string == 10
            Cn = bin2dec(protocol(1,6));
            Man = bin2dec(protocol(1,7:8));
            nA  = bin2dec(protocol(1,9:13));
            tau_An = bin2dec(protocol(1,14:23));
            lamda_An = bin2dec(append(protocol(1,24:32),protocol(2,1:12)));
            del_i_An = bin2dec(protocol(2,13:30));
            e_An = bin2dec(append(protocol(2,31:32),protocol(3,1:13)));
        elseif string == 11
            w_An = bin2dec(protocol(1,6:21));
            tau_Alam = bin2dec(append(protocol(1,22:32),protocol(2,1:10)));
            del_T_An = bin2dec(protocol(2,11:32));
            del_dotT_An = bin2dec(protocol(3,1:7));
            del_H_An = bin2dec(protocol(3,8:12));
            ln = bin2dec(protocol(3,13));
        elseif string == 12
            Cn = bin2dec(protocol(1,6));
            Man = bin2dec(protocol(1,7:8));
            nA  = bin2dec(protocol(1,9:13));
            tau_An = bin2dec(protocol(1,14:23));
            lamda_An = bin2dec(append(protocol(1,24:32),protocol(2,1:12)));
            del_i_An = bin2dec(protocol(2,13:30));
            e_An = bin2dec(append(protocol(2,31:32),protocol(3,1:13)));
        elseif string == 13
            w_An = bin2dec(protocol(1,6:21));
            tau_Alam = bin2dec(append(protocol(1,22:32),protocol(2,1:10)));
            del_T_An = bin2dec(protocol(2,11:32));
            del_dotT_An = bin2dec(protocol(3,1:7));
            del_H_An = bin2dec(protocol(3,8:12));
            ln = bin2dec(protocol(3,13));
        elseif string == 14
            B1 = bin2dec(protocol(1,11));
            B2 = bin2dec(protocol(1,11:20));
            KP = bin2dec(protocol(1,21:22));
        end
    end
end