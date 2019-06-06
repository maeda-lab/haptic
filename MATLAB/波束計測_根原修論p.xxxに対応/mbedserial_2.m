close all;          % close all figures
clc;                % clear the command line
fclose('all');      % close all open files
clear all;
delete(instrfindall); % Reset Com Port
%delete(timerfindall); % Delete Timers

% scale factor [LSB/g]
sf = 1000.0;

s = serial('COM3','Baudrate',921600);
% s.Status
%s.InputBufferSize = 92;
%s.OutputBufferSize = 92;
s.Terminator = 'LF' ;

str='';

Fs = 1250;  %2ch     % Sampling frequency
%Fs = 1000;   %4ch
T = 1/Fs;             % Sampling period
L = 210;              % Length of signal
Ld = 512;
t = (0:L-1)*T;        % Time vector
freq = 40;
[y,fs] = audioread('40-249.wav');

%{
fs=44100;
t1=0:1/fs:1;
f = 30;
y1 = sin(2*pi*f*t1);
y2 = sin(2*pi*f*2*t1);
y3 = sin(2*pi*f*3*t1);
y4 = sin(2*pi*f*4*t1);
y5 = sin(2*pi*f*5*t1);
y6 = sin(2*pi*f*6*t1);
y7 = sin(2*pi*f*7*t1);
y = [y1 y2 y3 y4 y5 y6 y7];
%}
player = audioplayer(y,fs);

row_data = zeros(Fs*L,4); %2ch
%row_data = zeros(Fs*L,5); %4ch
zdata = zeros(Ld,2);
Phase = zeros(1,L);



try
    fopen(s);
    pause(1);
    
    %wavçƒê∂
    play(player);
        
    j=0;
    while(j<Fs*L) 
            %ì«Ç›çûÇ›
            str = fgets(s);
            %M = textscan(str,'%f','Delimiter',',');
            if (numel(sscanf(str,'%f')) == 4) %2ch
            %if (numel(sscanf(str,'%f')) == 5) %4ch
            row_data(j+1,:) = sscanf(str,'%f');
            end
            %{
            if (j >2000 && numel(M) ==8)
            row_data(j,:) = transpose(M);
            end
            %}
            j = j+1;
    
    end    
   
        
        fclose(s);
        delete(s);
        figure;
        plot(row_data(:,1))
   
    
catch ME
    
    fclose(s);
    delete(s);
    
    
    display('finished');
   
end

     
    while(freq<250)    
%Fs=1250Hz,2ch

        zdata(:,1) = row_data(700+1250*(freq-40):1211+1250*(freq-40),1);
        zdata(:,2) = row_data(700+1250*(freq-40):1211+1250*(freq-40),3);

%Fs=1000Hz,4ch
 %       zdata(:,1) = row_data(400+1000*(freq-40):911+1000*(freq-40),1);
  %      zdata(:,2) = row_data(400+1000*(freq-40):911+1000*(freq-40),2);
        
%{        
        zdata(:,1) = row_data(200+1250*(freq-40):1223+1250*(freq-40),1);
        zdata(:,2) = row_data(200+1250*(freq-40):1223+1250*(freq-40),3);
%}        
        
        %à ëäç∑ÇãÅÇﬂÇÈ
        [acor,lag] = xcorr(zdata(:,2),zdata(:,1));
        %[acor,lag] = xcorr(zdata(1:int8(Fs/freq),2),zdata(1:int8(Fs/freq),1));
        [~,I] = max(acor);

        lagDiff = lag(I);
        if(lagDiff<0)
            lagDiff = Fs/freq + lagDiff;
        end
        timeDiff = lagDiff/Fs;
        Phase(1,freq-39) = 2*timeDiff*freq;
        
        if (Phase(1,freq-39) > 2) 
           Phase(1,freq-39) = Phase(1,freq-39)  - fix(Phase(1,freq-39)/2)*2;
        end
        
        if (Phase(1,freq-39)<=-2)
           Phase(1,freq-39) = Phase(1,freq-39)  - fix(Phase(1,freq-39)/2)*2;
        end
        
        if (Phase(1,freq-39) < 0)            
            Phase(1,freq-39) = 2 + Phase(1,freq-39);
            %Phase(1,freq-39) = -Phase(1,freq-39);
            
        end
        
      
        %{
        Y1 = fft(zdata(:,1));
        Y2 = fft(zdata(:,2));
        P1 = angle(Y1);
        P2 = angle(Y2);
        
        Phase(1,freq-39) = (P1(int8(freq*Fs/(2*Ld)))-P2(int8((freq*Fs/(2*Ld)))))/pi;
        if (Phase(1,freq-39) < 0)            
            Phase(1,freq-39) = Phase(1,freq-39)+2;
        end
       %}
        
        freq = freq+1;
        
    end   


figure;
f = 40:249;
p = Phase(1,1:L);
plot(f,p)
xlabel 'Frequency (Hz)'
ylabel 'Phase (rad/ÉŒ)'

display('finished');
display('csv_outputting');  
     k=1;
     while(k<Fs*L) 
            %csv1
            if k==1
            dlmwrite('test.csv',row_data(k,:));
            else
            dlmwrite('test.csv',row_data(k,:),'-append');
            end
       
            %hasoku_gel_5_Skin_7cm_2
            
            k = k+1;
    
    end    
  

display('csv_output_finished');
 
