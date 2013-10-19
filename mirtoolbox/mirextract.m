function exit_status = mirextract(indir, outdir)
%
% Helper function to run batch MIRToolbox extraction for:
%   - MFCC
%   - Spectral Shape (Centroid, Spread, Skewness, Kurtosis)
%   - Spectral Flux
%

%
% Build up the dataflow
%
mirflow = mirstruct;

mirflow.tmp.s = mirspectrum('Design','Frame',0.02322,0.5);
mirflow.mfcc = mirmfcc(mirflow.tmp.s);
mirflow.cent = mircentroid(mirflow.tmp.s);
mirflow.spread = mirspread(mirflow.tmp.s);
mirflow.skew = mirskewness(mirflow.tmp.s);
mirflow.kurt = mirkurtosis(mirflow.tmp.s);
mirflow.flux = mirflux(mirflow.tmp.s);

%
% Run extraction on all wav files in the dir
%
recur_extract(indir, outdir, mirflow);

exit_status = 0;

end

function exit_status = recur_extract(indir, outdir, flow)
% Recursively run extraction on all wav files

files = dir(indir);

for i=1:length(files)
    file = files(i);
    if file.isdir && ~strcmp(file.name, '.') && ~strcmp(file.name, '..')
        recur_extract(fullfile(indir, file.name), outdir, flow);
    elseif ~file.isdir
        [folder, name, extension] = fileparts(fullfile(indir, file.name));
        if strcmp(extension, '.wav')
            
            %
            % Run extraction on the wav file
            %
            output = mireval(flow, fullfile(indir, file.name));
            
            %
            % Write out the features to csv files
            %
            base = strcat(outdir, '/', name);
            
            csvwrite(strcat(base, '.mfcc', '.csv'), transpose(mirgetdata(output.mfcc)));
            
            cent = transpose(mirgetdata(output.cent));
            spread = transpose(mirgetdata(output.spread));
            skew = transpose(mirgetdata(output.skew));
            kurt = transpose(mirgetdata(output.kurt));
            csvwrite(strcat(base, '.shape', '.csv'), [cent, spread, skew, kurt]);
            
            csvwrite(strcat(base, '.flux', '.csv'), transpose(mirgetdata(output.flux)));
        end
    end
end

exit_status = 0;

end

