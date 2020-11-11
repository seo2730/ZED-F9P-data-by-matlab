function x = GPS_GetEphemeris(ephemeris_raw_data)
    raw_data = fliplr(ephemeris_raw_data);
    protocol = char(zeros(10,32));
    for j = 1:10
        for i = 1:4
             protocol(j,(8*(i)-7):8*(i)) = dec2bin(hex2dec(raw_data(j,i)),8);
        end
    end
    subframe = bin2dec(protocol(2,20:22));
    
    if subframe == 1
        WN = protocol(3,3:12);
        toc = protocol(8,11:26);
        af1 = protocol(9,3:10);
        af2 = protocol(9,11:26);
        af3 = protocol(10,3:24);
    elseif subframe == 2
        Crs = protocol(3,11:26);
        del_n = protocol(4,3:18);
        M0 = append(protocol(4,19:26),protocol(5,3:26));
        Cus = protocol(6,3:18);
        e = append(protocol(6,19:26),protocol(7,3:26));
        Cus = protocol(8,3:18);
        root_A = append(protocol(8,19:26),protocol(9,3:26));
        toe = protocol(10,3:18);
    elseif subframe == 3
        Cic = protocol(3,3:18);
        omega0 = append(protocol(3,19:26),protocol(4,3:26));
        Cis = protocol(5,3:18);
        i0 = append(protocol(5,19:26),protocol(6,3:26));
        Crc = protocol(7,3:18);
        w = append(protocol(7,19:26),protocol(8,3:26));
        dot_omega = protocol(9,3:26);
        dot_i = protocol(10,11:24);
    end    
end