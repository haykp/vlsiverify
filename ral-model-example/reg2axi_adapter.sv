// The driver can only handel sequence_items. It does now know how to work with registers
// But RAL user interface works with uvm_reg_bus_op objects. These objects contains all operations that someone needs to do with the registers
// for example read, write, read-modify-write and so on. So these are the user api to work with register
// Now we need some mechanism to translate the user api to driver understandable objects, in other words we need some translator/adaptor class which will
// take the uvm_reg_bus_op objects and translate them to sequence_items. 
// And that class is uvm_req_adapter with its predefined: reg2bus, bus2reg methods.
// When user impmements these methods that everything is done.
class reg_axi_adapter extends uvm_reg_adapter;
  `uvm_object_utils(reg_axi_adapter)
  
  function new(string name = "reg_axi_adapter");
    super.new(name);
  endfunction
  
  virtual function uvm_sequence_item reg2bus (const ref uvm_reg_bus_op rw);
    seq_item bus_item = seq_item::type_id::create("bus_item");
    bus_item.addr = rw.addr;
    bus_item.data = rw.data;
    bus_item.rd_or_wr = (rw.kind == UVM_READ) ? 1: 0;
    
    `uvm_info(get_type_name(), $sformatf("reg2bus: addr = %0h, data = %0h, rd_or_wr = %0h", bus_item.addr, bus_item.data, bus_item.rd_or_wr), UVM_LOW);
    return bus_item;
  endfunction
  
  virtual function void bus2reg (uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    seq_item bus_pkt;
    if(!$cast(bus_pkt, bus_item))
      `uvm_fatal(get_type_name(), "Failed to cast bus_item transaction")

    rw.addr = bus_pkt.addr;
    rw.data = bus_pkt.data;
    rw.kind = (bus_pkt.rd_or_wr) ? UVM_READ: UVM_WRITE;
  endfunction
endclass
