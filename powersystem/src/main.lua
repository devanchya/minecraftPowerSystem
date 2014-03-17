-- LUA script for base on 8bitmc.com world TPPI
-- This a personal script and most likely useless for everyone else

local function getOverrideSignal ( )
  local cs=peripheral.wrap('bottom')
  cs.open(1)
  local _, side, freq, rfreq, message = {os.pullEvent}
  return message
end

local function getRodPercent ( rodNum )
  return (100-(reactor.getControlRodLevel( rodNum )))
end

local function setReactorStatus( )
-- shutdown or startup reactor
  if overrideFlag==true then
      reactor.setAllControlRodLevels(100)
      reactor.setActive(false)
  end
end

emptyflag=0
offlineflag=0
flashflag=0
overrideFlag=0

bigreactor = 'BigReactors-Reactor_0'
energycell1 = 'cofh_thermalexpansion_energycell_4'
energycell2 = 'cofh_thermalexpansion_energycell_3'
overridecomputer = 'computer_2'

monitor=peripheral.wrap('top')
monitor.setTextScale(1)
monitor.setBackgroundColor(colors.black)


if peripheral.wrap(bigreactor) ~= nil then
  reactor=peripheral.wrap(bigreactor)
else
  error('Big Reactor is not connected')
  return
end

if peripheral.wrap(energycell1) ~= nil then
  cellHead=peripheral.wrap(energycell1)
else
  error('Top Energy Cell is not connected')
  return
end

if peripheral.wrap(energycell2) ~= nil then
  cellTail=peripheral.wrap(energycell2)
else
  error('Bottom Energy Cell is not connected')
  return
end

if peripheral.wrap(overridecomputer) ~= nil then
  overideSwitch=peripheral.wrap(overridecomputer)
else
  error('Override Switch not connected')
  return
end

overrideWatch = coroutine.create( getOverrideSignal )

print('ReactorControl Engaged. View Monitor.')

while true do
  monitor.clear()
  monitor.setCursorPos(1,1)
  monitor.setTextColor(colors.white)
  monitor.write('Fuel Level:')
  monitor.setCursorPos(1,2)
  monitor.setTextColor(colors.yellow)
  monitor.write(math.floor(((reactor.getFuelAmount()/reactor.getFuelAmountMax())*100)+0.5)..'% Fuel')
  monitor.setCursorPos(1,3)
  monitor.setTextColor(colors.lightBlue)
  --We really don't care about waste since it is being auto-converted
  --monitor.write(math.floor(((reactor.getWasteAmount()/reactor.getFuelAmountMax())*100)+0.5)..'% Waste')
  monitor.setCursorPos(1,5)
  monitor.setTextColor(colors.white)
  monitor.write('Control Rod Levels:')
  monitor.setTextColor(colors.green)
  monitor.setCursorPos(1,6)
  monitor.write('Rod 1:  '..getRodPercent(0)..'% ')
  monitor.setCursorPos(1,7)
  monitor.write('Rod 2:  '..getRodPercent(1)..'% ')
  monitor.setCursorPos(1,8)
  monitor.write('Rod 3:  '..getRodPercent(2)..'% ')
  monitor.setCursorPos(20,6)
  monitor.write('Rod 4:  '..getRodPercent(3)..'% ')
  monitor.setCursorPos(20,7)
  monitor.write('Rod 5:  '..getRodPercent(4)..'% ')
  
  
  monitor.setCursorPos(1,9)
  monitor.setTextColor(colors.white)
  monitor.write('Temperature:')
  monitor.setCursorPos(15,9)
  if reactor.getTemperature()>=650 then
      monitor.setTextColor(colors.purple)
      else if reactor.getTemperature()>=950 then
          monitor.setTextColor(colors.red)
      else
          monitor.setTextColor(colors.green)
      end
  end
  monitor.write(reactor.getTemperature()..'C')
  monitor.setCursorPos(1,10)
  monitor.setTextColor(colors.white)
  monitor.write('Flux:')
  monitor.setCursorPos(1,11)
  monitor.setTextColor(colors.green)
  monitor.write(reactor.getEnergyStored()..' RF Stored      ')
  
  cellHeadStored=cellHead.getEnergyStored('top')
  cellTailStored=cellTail.getEnergyStored('top')
  
  
  if reactor.getEnergyProducedLastTick()>=500 and reactor.getEnergyProducedLastTick()<2000 then
      monitor.setTextColor(colors.orange)
  end
  
  if reactor.getEnergyProducedLastTick()>=2000 then
      monitor.setTextColor(colors.red)
  end
  
  monitor.write((math.floor(reactor.getEnergyProducedLastTick()+0.5))..'RF/t')
  monitor.setCursorPos(15,1)
  monitor.setTextColor(colors.orange)
  
  overrideFlag = coroutine.resume( overrideWatch )
  if coroutine.status( overrideWatch ) == "dead" then
    overrideWatch = coroutine.create( getOverrideSignal )
  end
  
  if overrideFlag==true then
    if flashflag==0 then
      flashflag=1
      if offlineflag==1 then
        monitor.setCursorPos(15,1)
        monitor.setTextColor(colors.lightGray)
        monitor.write('OFFLINE - Manual Override')
      end
      if emptyflag==1 then
        monitor.setCursorPos(15,1)
        monitor.setTextColor(colors.pink)
        monitor.write('OFFLINE - Fuel Exhausted')
      end
      if emptyflag==0 and offlineflag==0 and reactor.getControlRodLevel(0)>75 then
        monitor.setCursorPos(15,1)
        monitor.setTextColor(colors.yellow)
        monitor.write('ONLINE - Low Power Mode')
      end
      if emptyflag==0 and offlineflag==0 and reactor.getControlRodLevel(0)<=75 then
        monitor.setCursorPos(15,1)
        monitor.setTextColor(colors.orange)
        monitor.write('ONLINE - High Power Mode')
      end
    else
      flashflag=0
      monitor.setCursorPos(1,13)
      monitor.clearLine()
    end
     
    if reactor.getEnergyStored()>=1 and reactor.getTemperature()<=900 and emptyflag==0 and offlineflag==0 then
        reactor.setAllControlRodLevels(math.floor(reactor.getEnergyStored()/100000))
    else
      if reactor.getEnergyStored()==0 and emptyflag==0 and offlineflag==0 then
          reactor.setAllControlRodLevels(math.floor(reactor.getTemperature()/10))
      else
         reactor.setAllControlRodLevels(80)
      end
    end
    
    if reactor.getFuelAmount()<=100 and offlineflag==0 then
        reactor.setAllControlRodLevels(100)
        reactor.setActive(false)
        emptyflag=1
    else
        emptyflag=0
    end
          
    if rs.getInput('top')==false and emptyflag==0 then
        reactor.setActive(true)
        offlineflag=0
    end
      
    if rs.getInput('top')==true and emptyflag==0 then
        reactor.setActive(false)
        reactor.setAllControlRodLevels(100)
        offlineflag=1
    end
 else
        setReactorStatus( "override" )
        monitor.setCursorPos(15,1)
        monitor.setTextColor(colors.lightGray)
        monitor.write('OFFLINE - Manual Override') 
 end   
  
  monitor.setTextColor(colors.white)
  monitor.setCursorPos(1,14)
  monitor.write('Top Cell'..cellHeadStored)
  monitor.setCursorPos(1,15)
  monitor.write('Top Cell'..cellTailStored)
  
  sleep(1)
end