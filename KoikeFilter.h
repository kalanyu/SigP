/*! @file
@brief FIR型ローパスフィルタ
@author Masato WATANABE
*/
#pragma once
#include "FirFilter.h"

class CKoikeFilter : public CFirFilter{
public:
    int bufferSize;
	CKoikeFilter(int size = 100);
	virtual ~CKoikeFilter();
};