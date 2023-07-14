-- modifiable variables
local reactorSide = "back"
local fluxgateSide = "right"

local targetStrength = 50
local maxTemperature = 8000
local safeTemperature = 3000
local lowestFieldPercent = 15

local activateOnCharged = 1

-- please leave things untouched from here on
os.loadAPI("lib/f")

local version = "0.25"
-- toggleable via the monitor, use our algorithm to achieve our target field strength or let the user tweak it
local autoInputGate = 1
local curInputGate = 180000

-- monitor 
local mon, monitor, monX, monY

-- peripherals
local reactor
local fluxgate
local inputfluxgate

-- reactor information
local ri

local emergencyCharge = false
local emergencyTemp = false

monitor = f.periphSearch("monitor")
inputfluxgate = f.periphSearch("flux_gate")
fluxgate = peripheral.wrap(fluxgateSide)
reactor = peripheral.wrap(reactorSide)



if monitor == null then
	print("No valid monitor was found")
else
  
end

if fluxgate == null then
	error("No valid fluxgate was found")
end

if reactor == null then
	error("No valid reactor was found")
end

if inputfluxgate == null then
	error("No valid flux gate was found")
end


function monitorcheck()
    monitor = f.periphSearch("monitor")
end


--write settings to config file
function save_config()
  sw = fs.open("config.txt", "w")   
  sw.writeLine(version)
  sw.writeLine(autoInputGate)
  sw.writeLine(curInputGate)
  sw.close()
end

--read settings from file
function load_config()
  sr = fs.open("config.txt", "r")
  version = sr.readLine()
  autoInputGate = tonumber(sr.readLine())
  curInputGate = tonumber(sr.readLine())
  sr.close()
end


-- 1st time? save our settings, if not, load our settings
if fs.exists("config.txt") == false then
  save_config()
else
  load_config()
end

function buttons()

  while true do
    -- button handler
    event, side, xPos, yPos = os.pullEvent("monitor_touch")
    ri = reactor.getReactorInfo()
    -- output gate controls
    -- 2-4 = -1000, 6-9 = -10000, 10-12,8 = -100000
    -- 17-19 = +1000, 21-23 = +10000, 25-27 = +100000
    if yPos == 4 then
      if ri.status == "running" and xPos >= 35 and xPos <= 37 then
        reactor.stopReactor()
      elseif ri.status == "cold" and xPos >= 35 and xPos <= 37 then
        reactor.chargeReactor()
      elseif ri.status == "warming_up" and xPos >= 35 and xPos <= 37 then
        reactor.activateReactor()
      end
    end

    if yPos == 13 then
      local cFlow = fluxgate.getSignalLowFlow()
      if xPos >= 2 and xPos <= 4 then
        cFlow = cFlow-1000
      elseif xPos >= 6 and xPos <= 9 then
        cFlow = cFlow-10000
      elseif xPos >= 10 and xPos <= 12 then
        cFlow = cFlow-100000
      elseif xPos >= 28 and xPos <= 31 then
        cFlow = cFlow+100000
      elseif xPos >= 32 and xPos <= 36 then
        cFlow = cFlow+10000
      elseif xPos >= 36 and xPos <= 39 then
        cFlow = cFlow+1000
      end
      fluxgate.setSignalLowFlow(cFlow)
    end

    -- input gate controls
    -- 2-4 = -1000, 6-9 = -10000, 10-12,8 = -100000
    -- 17-19 = +1000, 21-23 = +10000, 25-27 = +100000
    if yPos == 15 and autoInputGate == 0 and xPos ~= 20 and xPos ~= 21 then
      if xPos >= 2 and xPos <= 4 then
        curInputGate = curInputGate-1000
      elseif xPos >= 6 and xPos <= 9 then
        curInputGate = curInputGate-10000
      elseif xPos >= 10 and xPos <= 12 then
        curInputGate = curInputGate-100000
      elseif xPos >= 28 and xPos <= 31 then
        curInputGate = curInputGate+100000
      elseif xPos >= 32 and xPos <= 36 then
        curInputGate = curInputGate+10000
      elseif xPos >= 36 and xPos <= 39 then
        curInputGate = curInputGate+1000
      end
      inputfluxgate.setSignalLowFlow(curInputGate)
      save_config()
    end

    -- input gate toggle
    if yPos == 15 and ( xPos == 20 or xPos == 21) then
      if autoInputGate == 1 then
        autoInputGate = 0
      else
        autoInputGate = 1
      end
      save_config()
    end
  end
end

function drawButtons(y)

  -- 2-4 = -1000, 6-9 = -10000, 10-12,8 = -100000
  -- 17-19 = +1000, 21-23 = +10000, 25-27 = +100000

  f.draw_text(mon, 2, y, " < ", colors.white, colors.gray)
  f.draw_text(mon, 6, y, " <<", colors.white, colors.gray)
  f.draw_text(mon, 10, y, "<<<", colors.white, colors.gray)

  f.draw_text(mon, 28, y, ">>>", colors.white, colors.gray)
  f.draw_text(mon, 32, y, ">> ", colors.white, colors.gray)
  f.draw_text(mon, 36, y, " > ", colors.white, colors.gray)
end


function update()
  while true do 
    monitorcheck()
    if monitor == null then
    else
      monX, monY = monitor.getSize()
      mon = {}
      mon.monitor,mon.X, mon.Y = monitor, monX, monY
      f.clear(mon)
    end

    ri = reactor.getReactorInfo()

    -- print out all the infos from .getReactorInfo() to term

    if ri == nil then
      error("reactor has an invalid setup")
    end

    for k, v in pairs (ri) do 
      if v == true then
        print(k.. ": ".. tostring(v))
      elseif v == false then
        print(k.. ": ".. tostring(v))
      else
        print(k.. ": ".. v)
      end
    end
		
    print("Output Gate: ", fluxgate.getSignalLowFlow())
    print("Input Gate: ", inputfluxgate.getSignalLowFlow())

    -- monitor output

    local fuelPercent, fuelColor

    fuelPercent = 100 - math.ceil(ri.fuelConversion / ri.maxFuelConversion * 10000)*.01

    local satPercent
    satPercent = math.ceil(ri.energySaturation / ri.maxEnergySaturation * 10000)*.01
	print(ri.energySaturation)
    local fieldPercent, fieldColor
    fieldPercent = math.ceil(ri.fieldStrength / ri.maxFieldStrength * 10000)*.01
    if monitor == null then
      print("No valid monitors was found")
    else
              local statusColor
              statusColor = colors.red

              if ri.status == "running" then
                statusColor = colors.green
              elseif ri.status == "cold" then
                statusColor = colors.gray
              elseif ri.status == "warming_up" then
                statusColor = colors.orange
              end
              f.draw_text_lr(mon, 2, 2, 1, "Reactor Status", string.upper(ri.status), colors.white, statusColor, colors.black)
              if ri.status == "running" then
                f.draw_text(mon, 35, 4, "STOP", colors.red, colors.gray)
              elseif ri.status == "cold" or ri.status == "warming_up" then
                f.draw_text(mon, 35, 4, "START", colors.lime, colors.gray)
              end
              f.draw_text_lr(mon, 2, 9, 1, "Generation", f.format_int(ri.generationRate) .. " rf/t", colors.white, colors.lime, colors.black)
              f.draw_text_lr(mon, 2, 10, 1, "Output", (f.format_int(ri.generationRate - inputfluxgate.getSignalLowFlow())) .. " rf/t", colors.white, colors.lime, colors.black)

              local tempColor = colors.red
              if ri.temperature <= 5000 then tempColor = colors.green end
              if ri.temperature >= 5000 and ri.temperature <= 6500 then tempColor = colors.orange end
              f.draw_text_lr(mon, 2, 11, 1, "Temperature", f.format_int(ri.temperature) .. "C", colors.white, tempColor, colors.black)

              f.draw_text_lr(mon, 2, 12, 1, "Output Gate", f.format_int(fluxgate.getSignalLowFlow()) .. " rf/t", colors.white, colors.blue, colors.black)

              -- buttons
              drawButtons(13)

              f.draw_text_lr(mon, 2, 14, 1, "Input Gate", f.format_int(inputfluxgate.getSignalLowFlow()) .. " rf/t", colors.white, colors.blue, colors.black)

              if autoInputGate == 1 then
                f.draw_text(mon, 20, 15, "AUTO", colors.white, colors.gray)
              else
                f.draw_text(mon, 18, 15, "MANUEL", colors.white, colors.gray)
                drawButtons(15)
              end

              f.draw_text_lr(mon, 2, 17, 1, "Energy Saturation", satPercent .. "%", colors.white, colors.white, colors.black)
              f.progress_bar(mon, 2, 18, mon.X-2, satPercent, 100, colors.blue, colors.gray)

              fieldColor = colors.red
              if fieldPercent >= 50 then fieldColor = colors.green end
              if fieldPercent < 50 and fieldPercent > 30 then fieldColor = colors.orange end
              if autoInputGate == 1 then 
                f.draw_text_lr(mon, 2, 20, 1, "Field Strength T:" .. targetStrength, fieldPercent .. "%", colors.white, fieldColor, colors.black)
              else
                f.draw_text_lr(mon, 2, 20, 1, "Field Strength", fieldPercent .. "%", colors.white, fieldColor, colors.black)
              end
              f.progress_bar(mon, 2, 21, mon.X-2, fieldPercent, 100, fieldColor, colors.gray)

              fuelColor = colors.red

              if fuelPercent >= 70 then fuelColor = colors.green end
              if fuelPercent < 70 and fuelPercent > 30 then fuelColor = colors.orange end

              f.draw_text_lr(mon, 2, 23, 1, "Fuel ", fuelPercent .. "%", colors.white, fuelColor, colors.black)
              f.progress_bar(mon, 2, 24, mon.X-2, fuelPercent, 100, fuelColor, colors.gray)
    end
    
    -- actual reactor interaction
    --
    if emergencyCharge == true then
      reactor.chargeReactor()
    end
    
    -- are we charging? open the floodgates
    if ri.status == "warming_up" then
      inputfluxgate.setSignalLowFlow(900000)
      emergencyCharge = false
    end

    -- are we stopping from a shutdown and our temp is better? activate
    if emergencyTemp == true and ri.status == "stopping" and ri.temperature < safeTemperature then
      reactor.activateReactor()
      emergencyTemp = false
    end

    -- are we charged? lets activate
    if ri.status == "charged" and activateOnCharged == 1 then
      reactor.activateReactor()
    end
    -- are we on? regulate the input fludgate to our target field strength
    -- or set it to our saved setting since we are on manual
    if ri.status == "running" then
      if autoInputGate == 1 then 
        fluxval = ri.fieldDrainRate / (1 - (targetStrength/100) )
        print("Target Gate: ".. fluxval)
        inputfluxgate.setSignalLowFlow(fluxval)
	curInputGate = fluxval
      else
        inputfluxgate.setSignalLowFlow(curInputGate)
      end
    end

    -- safeguards
    --
    
    -- out of fuel, kill it
    if fuelPercent <= 10 then
      reactor.stopReactor()
    end

    -- field strength is too dangerous, kill and it try and charge it before it blows
    if fieldPercent <= lowestFieldPercent and ri.status == "running" then
      reactor.stopReactor()
      reactor.chargeReactor()
      emergencyCharge = true
    end

    -- temperature too high, kill it and activate it when its cool
    if ri.temperature > maxTemperature then
      reactor.stopReactor()
      emergencyTemp = true
    end

    monitorcheck()
    sleep(0.1)
  end
end

parallel.waitForAny(buttons, update)
