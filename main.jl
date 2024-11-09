using JSON
using Plots

# Data: https://tablebase.lichess.ovh/tables/standard/stats.json
data = JSON.parsefile("data/stats.json")

Keys = keys(data)
Values = values(data)

rtbw = [i["rtbw"]["bytes"] for i in Values]
rtbz = [i["rtbz"]["bytes"] for i in Values]
len = [length(i)-1 for i in Keys]

longest = []
for i in Values
    for j in i["longest"]
        append!(longest, j["ply"])
    end
end

hist = [i["histogram"] for i in Values]
white_hist = [i["white"] for i in hist]
black_hist = [i["black"] for i in hist]

white_win = [i["win"] for i in white_hist]
white_loss = [i["loss"] for i in white_hist]
black_win = [i["win"] for i in black_hist]
black_loss = [i["loss"] for i in black_hist]

hist_data = [white_win, white_loss, black_win, black_loss]
dtz = []
for i in hist_data
    for j in i
        n = 1
        for k in j
            if length(dtz) < n
                append!(dtz, k)
            else
                dtz[n] += k
            end
            n += 1
        end
    end
end

white_wdl = [i["wdl"] for i in white_hist]
black_wdl = [i["wdl"] for i in black_hist]

losses = [i["-2"]+i["-1"] for i in white_wdl] + [i["1"]+i["2"] for i in black_wdl]
draws = [i["0"] for i in white_wdl] + [i["0"] for i in black_wdl]
wins = [i["1"]+i["2"] for i in white_wdl] + [i["-2"]+i["-1"] for i in black_wdl]

total = losses+draws+wins
losses = losses./total
draws = draws./total
wins = wins./total

s = scatter(rtbw, rtbz, zcolor=len, c=:rainbow, colorbar=true, colorbar_title="Pieces", xscale=:log10, yscale=:log10, xlabel="WDL File Size (bytes)", ylabel="DTZ File Size (bytes)", title="File Sizes", legend=false)
display(s)

h = histogram(longest, bins=maximum(longest), yscale=:log10, bar_width=1, linecolor=nothing, xlabel="DTZ", ylabel="Endgames", title="Longest DTZ Histogram", legend=false)
display(h)

b = bar(range(0, step=1, length=length(dtz)), dtz, bar_width=1, linecolor=nothing, yscale=:log10, xlabel="DTZ", ylabel="Positions", title="DTZ Bar Plot", legend=false)
display(b)

s = scatter(wins, losses, zcolor=draws, c=:rainbow, colorbar=true, colorbar_title="Draw Rate", xlabel="Win Rate", ylabel="Loss Rate",  title="WDL Rates", legend=false)
display(s)
