/*! @file
@brief FIR�^���[�p�X�t�B���^
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