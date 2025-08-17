import React from 'react';

const DeleteIcon: React.FC<React.SVGProps<SVGSVGElement>> = (props) => {

    return (
        <svg
        xmlns='http://www.w3.org/2000/svg'
        width='24'
        height='24'
        viewBox='0 0 24 24'
        fill='currentColor'
        {...props}

        >
            <path d='M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zm3-9h2v6H9V10zm4 0h2v6h-2V10zM5 4v2h14V4h3v2c0 .55-.45 1-1 1H3c-.55 0-1-.45-1-1V4h3z' />
        </svg>
    );
    


}


export default DeleteIcon;
