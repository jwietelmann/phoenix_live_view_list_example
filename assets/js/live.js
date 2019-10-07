import {Socket} from "phoenix"
import LiveSocket, {View} from "phoenix_live_view"

// Monkey-patching the View class so we can spy on LiveView's diff updates

View.prototype.oldUpdate = View.prototype.update
View.prototype.update = function newUpdate(diff) {
  let length = JSON.stringify(diff).length
  document.getElementById('diff').innerHTML = `Length: ${length} (timestamp ${new Date().getTime()})\n${JSON.stringify(diff, null, 2)}`
  return this.oldUpdate(diff)
  
}

// Utility functions to support our LiveView SortedList hook

function removeDeletedChildElementsOf(parent) {
  for (let child of parent.querySelectorAll('[data-list-deleted="true"]')) {
    child.remove()
  }
}

function getElementOrder(el) {
  return parseFloat(el.getAttribute('data-list-order')) || Infinity
}

function compareElements(elementA, elementB) {
  return getElementOrder(elementA) - getElementOrder(elementB)
}

function sortChildElementsOf(parent) {
  const sorted = Array.prototype.slice.call(parent.children).sort(compareElements)

  parent.prepend(...sorted)
}

// Our hook definition

const SortedList = {
  updated() {
    removeDeletedChildElementsOf(this.el)
    sortChildElementsOf(this.el)
  }
}

// Configure LiveSocket with hooks.

const liveSocket = new LiveSocket("/live", Socket, {
  hooks: {
    SortedList,
  },
})

// Connect as usual.

liveSocket.connect()
