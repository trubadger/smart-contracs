const expectThrow = (text) => async (promise) => {
  try {
    await promise;
  } catch (error) {
    assert(error.message.search(text) >= 0, "Expected throw, got '" + error + "' instead")
    return
  }
  assert.fail('Expected throw not received')
}

const eventEmitted = (result, eventName, detector) => {
  for(let item of result.logs){
    if(!!item.event && item.event === eventName){
      if(detector === undefined || detector(item.args))
        return;
    }
  }
  assert(false, `event ${eventName} expected but not happened.`)
}

const eventNotEmitted = (result, eventName, detector) => {
  for(let item of result.logs){
    if(!!item.event && item.event === eventName){
      if(detector === undefined || detector(item.args))
        assert(false, `event ${eventName} not expected but happened.`)
    }
  }
}

module.exports =  {
  expectOutOfGas: expectThrow('out of gas'),
  expectRevert: expectThrow('revert'),
  expectInvalidJump: expectThrow('invalid JUMP'),
  eventEmitted,
  eventNotEmitted,
}