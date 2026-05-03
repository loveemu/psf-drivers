local kSongTableAddress = 0x009C6E
local kSongTableLength = 22

memory.usememorydomain("System Bus")

for bankIndex = 0, kSongTableLength - 1 do
  local bankPointerAddress = kSongTableAddress + bankIndex * 3

  local chunkAddress = memory.read_u24_le(bankPointerAddress)
  local chunkIndex = 0
  while true do
    local size = memory.read_u16_le(chunkAddress)
    if size == 0 then
      break
    end

    local spcAddress = memory.read_u16_le(chunkAddress + 2)
    print(string.format("%d,%d,$%06X,$%04X,%d", bankIndex, chunkIndex, chunkAddress, spcAddress, size))

    chunkAddress = chunkAddress + 4 + size
    chunkIndex = chunkIndex + 1
  end
end
