local p_chn = Proto.new("auml_chn", "Auml Channel data")

local f_chn_id = ProtoField.uint16("auml_chn.id", "Channel ID", base.DEC)
local f_chn_src = ProtoField.uint8("auml_chn.src", "Source", base.DEC)
local f_chn_value = ProtoField.uint16("auml_chn.value", "Value", base.DEC)

p_chn.fields = {
    f_chn_id,
    f_chn_src,
    f_chn_value
}

-- Fields to read
local f_can_id = Field.new("can.id")

function p_chn.dissector(tvb,pinfo,root)
    local subt
    local chn_id = f_can_id().tvb:bitfield( 8,16)
    local chn_src = f_can_id().tvb:bitfield(24, 8)
   
    local info = "Values:"
    for i=0,(tvb:len()/2)-1 do
        local chn_value = tvb(i*2,2)
        subt = root:add(p_chn, tvb)
        subt:add(f_chn_id,  chn_id+i)
        subt:add(f_chn_src, chn_src)
        subt:add(f_chn_value, chn_value)
        info = info .. string.format(" %d", chn_value:uint())
    end
    
    pinfo.cols.protocol = "chn"
    pinfo.cols.src = string.format("node %d", chn_src)
    pinfo.cols.dst = string.format("chn %d", chn_id)
    pinfo.cols.info = info
end

DissectorTable.get("auml.cls"):add(0xa,p_chn)
