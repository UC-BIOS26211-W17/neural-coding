%% Recreation - Osborne/Palmer 2008
%
% Garrett Healy
% 
% 25FEB2017
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This script is to use information theory to recreate the data
% modification completed by Stephanie Palmer. These data are from MT neurons
% in macaques (n=3) anesthetized with sufentanil. 
% 
% DATA -------------------------------------------------------------------
% 
% There are 13 directions + 1 null direction. 
% 
% Recordings made for 256ms, put into 2ms time bins for 3 monkeys. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all; 

% Creates a raster of one set of data, to visualize it. 

cell1 = load('cell_11l10.mat');

data1 = cell1.data;
dirs = cell1.dirs;

s=size(data1);

figure 
hold on 
xlabel('Time(ms)');ylabel('Direction');
title('Neural Spikes by Stimulus Direction');
for i = 1:s(1)
    for j= 1:s(2)-1
        for k = 1:s(3)
            if data1(i,j,k) == 1
                spkx = [i*2, i*2];
                spky = [dirs(j) - 5,dirs(j) + 5];
                line(spkx,spky,'color','k','LineWidth',1);
            else 
            end
        end
    end
end
hold off
%%
% Load 4 more cells in order to make a 'word'

cell2 = load('cell_11l18.mat');
data2 = cell2.data;
cell3 = load('cell_12r08.mat');
data3 = cell3.data;
cell4 = load('cell_14l07.mat');
data4 = cell4.data;
cell5 = load('cell_14l13.mat');
data5 = cell5.data;

% The data needs to be in 8ms time bins, currently it is in 2
% Since we are looking at it binarily, any point must either be 0 or 1. Any
% value 2 or higher is removed. 

s2=size(data2);s3=size(data3);s4=size(data4);s5=size(data5);
n = min([s(3);s2(3);s3(3);s4(3);s5(3)]);

% It can only create words for the number of trials in the data set with
% the smallest number of trials (otherwise you lose that letter of the
% word)

data1n = zeros(s(1)/4, s(2));
data2n = zeros(s(1)/4, s(2));
data3n = zeros(s(1)/4, s(2));
data4n = zeros(s(1)/4, s(2));
data5n = zeros(s(1)/4, s(2));

for i = 1:s(1)/4
    for j = 1:s(2)
        for k = 1:n
            data1n(i,j,k) = data1((4*i),j,k) + data1(((4*i)-1),j,k) + data1(((4*i)-2),j,k);
            if data1n(i,j,k)>=2
                data1n(i,j,k)=1;
            end
            data2n(i,j,k) = data2((4*i),j,k) + data2(((4*i)-1),j,k) + data2(((4*i)-2),j,k);
            if data2n(i,j,k)>=2
                data2n(i,j,k)=1;
            end
            data3n(i,j,k) = data3((4*i),j,k) + data3(((4*i)-1),j,k) + data3(((4*i)-2),j,k);
            if data3n(i,j,k)>=2
                data3n(i,j,k)=1;
            end
            data4n(i,j,k) = data4((4*i),j,k) + data4(((4*i)-1),j,k) + data4(((4*i)-2),j,k);
            if data4n(i,j,k)>=2
                data4n(i,j,k)=1;
            end
            data5n(i,j,k) = data5((4*i),j,k) + data5(((4*i)-1),k) + data5(((4*i)-2),j,k);
            if data5n(i,j,k)>=2
                data5n(i,j,k)=1;
            end
        end
    end
end


s = size(data1n);

words = strings(s(1),s(2),s(3));
for i = 1:s(1)
    for j = 1:s(2)
        for k = 1:s(3)
            words(i,j,k) = string(data1n(i,j,k))+string(data2n(i,j,k))+string(data3n(i,j,k))+ ...
                string(data4n(i,j,k))+string(data5n(i,j,k));
        end
    end
end


d = struct; 
d.first = data1n;
d.second = data2n;
d.third = data3n;
d.fourth = data4n;
d.fifth = data5n;
%%
% Compute the probability that there is a spike at any time in a given
% stimulus direction (P(n|t,theta), which will then be used to calculate
% the information

f = fieldnames(d);
pnt = zeros(s(1),s(2)); %probability matrix
temp1 = zeros(1,length(f));
temp2 = zeros(1,length(f)-1);
qi = zeros(s(1),s(2));
phi = zeros(s(1),s(2));
J = .16;


% Determining phi
phis = cell(1,length(f));
qis = cell(1,length(f));

for g=1:length(f)
    n = f{g};
    for i = 1:s(1)
        for j = 1:s(2)
            for k =1:s(3)
                qi(i,j) = qi(i,j) + d.(n)(i,j,k);
            end
        end
    end
    qi = qi/s(3);
    qis{g} = qi;
    sqi = size(qi);
    for i = 1:sqi(1)
        for j = 1:sqi(2)
            if qi(i,j) == 0
                phi(i,j) = 0;
            else 
                phi(i,j) = log(qi(i,j)/(1-qi(i,j)));
            end
        end
    end
    phis{g} = phi;
end


% Calculate the pn

pfire = zeros(1,length(f));
for i = 1:length(f)
    n=f{i};
    s = size(d.(n));
    temp3 = sum(d.(n));
    temp4 = sum(temp3);
    pfire(i) = sum(temp4);
    pfire(i) = pfire(i)/(s(1)*s(2)*s(3));
end

% Equation for probability (equation 4 in the paper)
% Sorry for the confusion, g is the i in the paper and k is the j. i and j
% here are for time and direction

z = zeros(1,length(f));
for i = 1:s(1)
    for j = 1:s(2)
        for g = 1:length(f)
            n1 = f{g};
            phi = phis{g};
            temp1(g) = phi(i,j)*sum(d.(n1)(i,j,:))/s(3);
            c=0;
            for k = 1:length(f)
                n2 = f{k};
                if k~=g 
                    c=c+1;
                    temp2(c) = (J/2)*(sum(d.(n1)(i,j,:))/s(3))*(sum(d.(n2)(i,j,:))/s(3));
                end
            end
            z(g) = exp(-pfire(g));
            pnt(i,j) = z(g)*exp(sum(temp1)+sum(temp2));
        end
    end
end


% Calculate the maximum information 

imax =-1*(pfire(1))*log2(pfire(1))-(pfire(2))*log2(pfire(2))-(pfire(3))*log2(pfire(3)) ...
    -(pfire(4))*log2(pfire(4))-(pfire(5))*log2(pfire(5));


% Calculate the information 

inf = zeros(s(1),s(2));

for i = 1:s(1)
    for j = 1:s(2)
        inf(i,j) = -1*pnt(i,j)*log2(pnt(i,j));
    end
end

st = sum(inf);

iwords = imax - ((1/(14*s(1)))*(sum(st)));










