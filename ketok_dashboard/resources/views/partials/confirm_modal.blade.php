<!-- Global Confirmation Modal using SweetAlert2 (Eliminates 'localhost says') -->
<script>
// Global function to trigger styled confirmation modal
function showConfirmDialog(options) {
    const isDanger = (options.type || 'danger') === 'danger';
    const isWarning = (options.type || 'danger') === 'warning';

    if (typeof Swal === 'undefined') {
        // Fallback if CDN is unreachable
        if (confirm(options.message || 'Apakah Anda yakin ingin melanjutkan?')) {
            if (typeof options.onConfirm === 'function') options.onConfirm();
        }
        return;
    }

    const brandPrimary = getComputedStyle(document.documentElement).getPropertyValue('--color-brand-primary').trim() || '#030813';
    const brandDanger = getComputedStyle(document.documentElement).getPropertyValue('--color-brand-danger').trim() || '#E53E3E';
    const brandWarning = getComputedStyle(document.documentElement).getPropertyValue('--color-brand-warning').trim() || '#E09A00';

    Swal.fire({
        title: options.title || 'Konfirmasi Tindakan',
        text: options.message || 'Apakah Anda yakin ingin melanjutkan?',
        icon: isDanger ? 'warning' : (isWarning ? 'warning' : 'info'),
        showCancelButton: true,
        confirmButtonColor: isDanger ? brandDanger : (isWarning ? brandWarning : brandPrimary),
        cancelButtonColor: '#9CA3AF',
        confirmButtonText: options.confirmButtonText || 'Ya, Lanjutkan',
        cancelButtonText: options.cancelButtonText || 'Batal',
        reverseButtons: true,
        focusCancel: true,
        customClass: {
            popup: 'rounded-2xl font-sans !p-6 !border !border-brand-border !shadow-2xl',
            title: '!text-lg !font-bold !text-brand-text !pt-2',
            htmlContainer: '!text-xs !text-brand-muted !mt-2 leading-relaxed',
            confirmButton: 'px-5 py-2.5 !rounded-xl !font-bold !text-xs !shadow-sm transition-all',
            cancelButton: 'px-4 py-2.5 !rounded-xl !font-semibold !text-xs !border !border-brand-border transition-all'
        }
    }).then((result) => {
        if (result.isConfirmed) {
            if (typeof options.onConfirm === 'function') {
                options.onConfirm();
            }
        }
    });
}

window.showConfirmDialog = showConfirmDialog;

// Intercept form submissions that have data-confirm attributes
document.addEventListener('DOMContentLoaded', () => {
    document.addEventListener('submit', function(e) {
        const form = e.target;
        if (!form || form._confirmed) return;

        if (form.hasAttribute('data-confirm-title') || form.hasAttribute('data-confirm-message')) {
            e.preventDefault();
            e.stopImmediatePropagation();

            showConfirmDialog({
                title: form.getAttribute('data-confirm-title') || 'Konfirmasi Tindakan',
                message: form.getAttribute('data-confirm-message') || 'Apakah Anda yakin ingin melanjutkan?',
                confirmButtonText: form.getAttribute('data-confirm-button') || 'Ya, Lanjutkan',
                cancelButtonText: form.getAttribute('data-confirm-cancel') || 'Batal',
                type: form.getAttribute('data-confirm-type') || 'danger',
                onConfirm: () => {
                    form._confirmed = true;
                    HTMLFormElement.prototype.submit.call(form);
                }
            });
        }
    }, true);
});
</script>
