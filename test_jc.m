clear all;
close all;

% Add src folder to path
if (isempty(strfind(pwd(), strcat(filesep, 'src'))))
    addpath('src');
    addpath('src/neuralcoding');
    addpath('Reconstruction');
    addpath('MT_data');
end

%load data
n = loadMTData(36);
c = getCoding(n); %36x384 array of spikes and silences
data = c.code(:,:,1,1)

%test
data20 = data(20,:)
data21 = data(21,:)
spike20 = find(data20 == 1)
spike21 = find(data21 == 1)
for i = 1:length(spike20)
    k = 0
    val20 = spike20(i)
    for j = 1:length(spike21)
        val21 = spike21(j)
        diff = abs(val20 - val21)
        if diff <= 5
            k = k+1
        end
    end
end