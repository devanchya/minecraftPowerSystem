-- LUA script for base on 8bitmc.com world TPPI
-- This a personal script and most likely useless for everyone else

local function getOverrideSignal ( )
  local modem=peripheral.wrap('bottom')
  modem.open(851,1)
  local _, side, freq, rfreq, message, distance = {os.pullEvent('modem_message')}
  monitor.setTextColor(colors.white)
  monitor.setCursorPos(1,12)
  monitor.write('Override Status: '..message)
  monitor.setCursorPos(1,13)
  monitor.write('->'..message..freq..rfreq..side)  
  print ('->'..message..freq..rfreq..side)  
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
monitor.clear()

local overrideWatch = coroutine.create( getOverrideSignal )
--print ('Create Check'.. overrideWatch )
local evt = {}

print('ReactorControl Engaged. View Monitor.')

while true do
  overrideSignal = coroutine.resume(overrideWatch, unpack(evt))
  print ('While Check'..message )
  if coroutine.status( overrideWatch ) == "dead" then
    overrideWatch = coroutine.create( getOverrideSignal )
    print ( 'Resetting Override Watch' )
  end

  evt = {os.pullEvent()}
  sleep(1)
end