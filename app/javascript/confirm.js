import swal from 'sweetalert'
import { Turbo } from '@hotwired/turbo-rails'

function showConfirm(
  message,
  { title = 'Are you sure?', confirmText = 'Confirm', dangerMode = false } = {}
) {
  return swal({
    title,
    text: message,
    buttons: ['Cancel', confirmText],
    dangerMode,
  }).then(v => !!v)
}

Turbo.config.forms.confirm = (message, element, submitter) => {
  const isDangerous =
    element?.method?.toLowerCase() === 'delete' ||
    submitter?.dataset?.turboConfirmDanger != null ||
    element?.dataset?.turboConfirmDanger != null
  return showConfirm(message, { dangerMode: isDangerous })
}
window.showConfirm = showConfirm
window.swal = swal

export default showConfirm
