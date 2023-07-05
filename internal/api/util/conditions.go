package util

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"

	cmapi "github.com/cert-manager/csi-lib/internal/apis/certmanager/v1"
)

func GetCertificateRequestCondition(req *cmapi.CertificateRequest, conditionType cmapi.CertificateRequestConditionType) *cmapi.CertificateRequestCondition {
	for _, cond := range req.Status.Conditions {
		if cond.Type == conditionType {
			return &cond
		}
	}
	return nil
}

// CertificateRequestIsApproved returns true if the CertificateRequest is
// approved via an Approved condition of status `True`, returns false
// otherwise.
func CertificateRequestIsApproved(cr *cmapi.CertificateRequest) bool {
	if cr == nil {
		return false
	}

	for _, con := range cr.Status.Conditions {
		if con.Type == cmapi.CertificateRequestConditionApproved &&
			con.Status == metav1.ConditionTrue {
			return true
		}
	}

	return false
}

// CertificateRequestIsDenied returns true if the CertificateRequest is denied
// via a Denied condition of status `True`, returns false otherwise.
func CertificateRequestIsDenied(cr *cmapi.CertificateRequest) bool {
	if cr == nil {
		return false
	}

	for _, con := range cr.Status.Conditions {
		if con.Type == cmapi.CertificateRequestConditionDenied &&
			con.Status == metav1.ConditionTrue {
			return true
		}
	}

	return false
}
