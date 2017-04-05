# ERPmine - ERP for service industry
# Copyright (C) 2011-2016  Adhi software pvt ltd
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

module WkbillingHelper
	include WktimeHelper
	#include WkinvoiceHelper
	include WkgltransactionHelper
	
	def postToGlTransaction(transObj, amount, currency)
		transId = transObj.gl_transaction.blank? ? nil : transObj.gl_transaction.id
		if transObj.class.name == "WkInvoice"
			transModule = 'invoice'
			transDate = transObj.invoice_date
		elsif transObj.class.name == "WkPayment"
			transModule = 'payment'
			transDate = transObj.payment_date
		end
		glTransaction = nil
		crLedger = WkLedger.where(:id => getSettingCfId("#{transModule}_cr_ledger"))
		dbLedger = WkLedger.where(:id => getSettingCfId("#{transModule}_db_ledger"))
		unless crLedger[0].blank? || dbLedger[0].blank?
			#transId = invoice.gl_transaction.blank? ? nil : invoice.gl_transaction.id
			transType = getTransType(crLedger[0].ledger_type, dbLedger[0].ledger_type)
			if Setting.plugin_redmine_wktime['wktime_currency'] == currency 
				isDiffCur = false 
			else
				isDiffCur = true 
			end
			glTransaction = saveGlTransaction(transModule, transId, transDate, transType, nil, amount, currency, isDiffCur)
		end
		glTransaction
	end
	
	def accountPolymormphicHash
		typeHash = {
			'WkAccount' => l(:label_account),
			'WkCrmContact' => l(:label_contact) 
		}
		typeHash
	end
end
