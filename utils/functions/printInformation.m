function printInformation( FRA, fID,  sweeps, channels )
arguments
    FRA
    fID = 1
    sweeps = []
    channels = 1
end
        fprintf( fID, "\n\tStatistical Information (number of spikes):"+...
                "\n\t\tMean:\t%f"+...
                "\n\t\tMedian:\t%f" +...
                "\n\t\tMode:\t%f" +...
                "\n\t\tStandard Deviation:\t%f" +...
                "\n\t\tVariance:\t%f" +...
                "\n\t\tMax:\t%f" +...
                "\n\t\tMin:\t%f" +...
                "\n\t\tTotal number of spikes:\t%f" +...
                "\n", FRA.stats.mean, FRA.stats.median, FRA.stats.mode,...
                FRA.stats.std, FRA.stats.var, FRA.stats.max, FRA.stats.min,...
                FRA.stats.total_spikes);

        if ~isempty(sweeps)
            cf = sweepToFreq( FRA.receptive_field.response_threshold, sweeps, channels );
            bf = sweepToFreq( FRA.receptive_field.best_frequency, sweeps, channels );
        else
            cf = FRA.receptive_field.response_threshold;
            bf = FRA.receptive_field.best_frequency;
        end
        
        fprintf( fID, "\n\tReceptive field (RF) information:"+...
            "\n\t\tSpikes in RF:\t%f"+...
            "\n\t\tArea of RF (%%):\t%f" +...
            "\n\t\tMinimum Threshold (dB SPL):\t%f" +...
            "\n\t\tCharacteristic Frequency, CF (Hz):\t%f" +...
            "\n\t\tBest Frequency, BF (Hz):\t%f" +...
            "\n\t\tDistance from CF to BF (octaves):\t%f" +...
            "\n\t\tBiggest frequency interval of RF (Hz):\t[%f, %f]"+...
            "\n\t\t\tSeparation (Hz):\t%f" +...
            "\n\t\t\tSeparation (Octaves):\t%f" +...
            "\n\t\tQ10:\t%f" +...
            "\n\t\tPeriphery threshold:\t%f" +...
            "\n\t\tCore threshold:\t%f" +...
            "\n", FRA.receptive_field.spikes_RF,...
            FRA.receptive_field.area_RF * 100,...
            FRA.receptive_field.minimum_threshold,...
            cf,...
            bf,...
            FRA.receptive_field.distance_to_BF_from_CF,...
            maxWidthRF(FRA.receptive_field.periphery_receptive_field.width_PRF, sweeps, channels),...
            FRA.receptive_field.Q10, FRA.receptive_field.periphery_receptive_field.periphery_threshold,...
            FRA.receptive_field.core_receptive_field.core_threshold);
    end