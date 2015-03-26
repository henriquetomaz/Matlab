function [A,newA]=cleanfreqs_mod(n,dir,M1,ch,out);

A=cell(ch,n);

for c=1:ch
    for k=1:n    
        s=size(M1{c,k},1);
        if s == 1
            A{c,k} = M1{c,k}
        end    
        g=0;
        h=0;
        C=0;
        for i=2:s
            if C==0 & abs(M1{c,k}(i-1,1)-M1{c,k}(i,1)) > 0.2 % substituir pelo deltaf (resol de freq)- (0,2)
                g=g+1;
                A{c,k}(g,1)=M1{c,k}(i-1,1);
                A{c,k}(g,2)=M1{c,k}(i-1,2);
                A{c,k}(g+1,1)=M1{c,k}(i,1);
                A{c,k}(g+1,2)=M1{c,k}(i,2);
                C=C+1;
                h=0;
            elseif C==0 & abs(M1{c,k}(i-1-h,1)-M1{c,k}(i,1)) <= 0.2*(h+1) % substituir pelo deltaf (resol de freq) - (0,2)
                if M1{c,k}(i-1-h,2) >= M1{c,k}(i,2)
                    A{c,k}(g+1,1)=M1{c,k}(i-1-h,1);
                    A{c,k}(g+1,2)=M1{c,k}(i-1-h,2);
                    C=C+1;
                    h=h+1;
                elseif M1{c,k}(i-1-h,2) < M1{c,k}(i,2)
                    A{c,k}(g+1,1)=M1{c,k}(i,1);
                    A{c,k}(g+1,2)=M1{c,k}(i,2);
                    C=C+1;
                    h=h+1;
                end
            elseif C~=0 & abs(M1{c,k}(i-1-h,1)-M1{c,k}(i,1)) > 0.22*(h+1) % substituir pelo deltaf (resol de freq) - (0,22)
                g=g+1;
                A{c,k}(g+1,1)=M1{c,k}(i,1);
                A{c,k}(g+1,2)=M1{c,k}(i,2);
                h=0;
            elseif C~=0 & abs(M1{c,k}(i-1-h,1)-M1{c,k}(i,1)) <= 0.22*(h+1) % substituir pelo deltaf (resol de freq) - (0,22)
                if M1{c,k}(i,2) >= A{c,k}(g+1,2)
                    A{c,k}(g+1,1)=M1{c,k}(i,1);
                    A{c,k}(g+1,2)=M1{c,k}(i,2);
                    C=C+1;
                    h=h+1;
                elseif M1{c,k}(i,2) < A{c,k}(g+1,2)
                    A{c,k}(g+1,1)=A{c,k}(g+1,1);
                    A{c,k}(g+1,2)=A{c,k}(g+1,2);
                    C=C+1;
                    h=h+1;
                end
            end
        end
    end
end

newA=cell(ch,n);

for c=1:ch
    for i=1:n
        nzeros=size(A{c,i},1)-length(find(A{c,i}(:,1)));
        length_newA(c,i)=length(find(A{c,i}(:,2)));
        for j=1:length_newA(c,i)
            for k=1:2 
                if A{c,i}(j,2)~=0
                    newA{c,i}(j,k)=A{c,i}(j,k);
                end
            end
        end
    end
end

%  Grava arquivo contendo os picos de Frequencia e suas potencias em cada canal de EEG analisado 
%  CREATE TEXT FILE
for c=1:ch
    file_path=[dir out{1,c} '-FreqPeaks.txt'];
    fid = fopen(file_path,'wt');
    fprintf(fid,'%s\t %s\t %s\n\n','Epoch','Fmax(Hz)','Intensity(uV2/Hz)'); 
    for k=1:n
        for i=1:size(newA{c,k},1)
            fprintf(fid,'%1.0f\t %2.2f\t\t %12.1f\n',k,newA{c,k}(i,1),newA{c,k}(i,2));
            fprintf(fid,'\n');
        end
    end 
    fclose(fid);
end

        